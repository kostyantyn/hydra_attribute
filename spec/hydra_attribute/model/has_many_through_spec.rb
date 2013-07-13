require 'spec_helper'

describe HydraAttribute::Model::HasManyThrough::Relation do
  def find_relation_object(attributes = {})
    HydraAttribute::HydraAttributeSet.all.find do |relation|
      attributes.all? do |attribute, value|
        relation.send(attribute) == value
      end
    end
  end

  describe '#build' do
    let(:hydra_set)  { Product.hydra_sets.create(name: 'default') }
    let(:hydra_attr) { Product.hydra_attributes.create(name: 'color', backend_type: 'string') }

    it 'should copy specific attribute to relation object' do
      attr = hydra_set.hydra_attributes.build(name: 'title', backend_type: 'string')
      attr.entity_type.should == 'Product'

      set = hydra_attr.hydra_sets.build(name: 'second')
      set.entity_type.should == 'Product'
    end

    it 'should save relation object after saving related object' do
      attr = hydra_set.hydra_attributes.build(name: 'title', backend_type: 'string')
      attr.should_not be_persisted
      hydra_set.save
      attr.should be_persisted
    end

    it 'should link to objects via relation table after saving main object' do
      attr = hydra_set.hydra_attributes.build(name: 'size', backend_type: 'integer')
      hydra_set.save

      relation = find_relation_object(hydra_set_id: hydra_set.id, hydra_attribute_id: attr.id)
      relation.should be_persisted
    end
  end

  describe '#create' do
    describe 'main object is persisted' do
      let(:hydra_attr) { Product.hydra_attributes.create(name: 'one', backend_type: 'string') }

      it 'should link objects via relation table' do
        set = hydra_attr.hydra_sets.create(name: 'default')
        set.should be_persisted

        relation = find_relation_object(hydra_set_id: set.id, hydra_attribute_id: hydra_attr.id)
        relation.should be_persisted
      end
    end

    describe 'main object is new object' do
      let(:hydra_attr) { Product.hydra_attributes.build(name: 'one', backend_type: 'string') }

      it 'should link objects via relation table after saving main object' do
        set = hydra_attr.hydra_sets.create(name: 'default')
        set.should be_persisted

        relation = find_relation_object(hydra_set_id: set.id, hydra_attribute_id: hydra_attr.id)
        relation.should be_nil

        hydra_attr.save
        relation = find_relation_object(hydra_set_id: set.id, hydra_attribute_id: hydra_attr.id)
        relation.should be_persisted
      end
    end
  end

  describe '#<<' do
    let(:build_method) { :create }
    let(:hydra_set)    { Product.hydra_sets.create(name: 'default') }
    let(:hydra_attr)   { Product.hydra_attributes.send(build_method, name: 'one', backend_type: 'string') }

    before { hydra_attr.hydra_sets << hydra_set }

    describe 'main object is persisted' do
      it 'should add relation object to collection' do
        hydra_attr.hydra_sets.should include(hydra_set)
      end

      it 'should link objects via relation table' do
        relation = find_relation_object(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attr.id)
        relation.should be_persisted
      end
    end

    describe 'main object is new object' do
      let(:build_method) { :build }

      it 'should add relation object to collection' do
        hydra_attr.hydra_sets.should include(hydra_set)
      end

      it 'should link objects via relation table after saving main object' do
        relation = find_relation_object(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attr.id)
        relation.should be_nil

        hydra_attr.save
        relation = find_relation_object(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attr.id)
        relation.should be_persisted
      end
    end
  end

  describe '#destroy' do
    let(:build_method) { :create }
    let(:hydra_set)    { Product.hydra_sets.send(build_method, name: 'default') }
    let(:hydra_attr)   { hydra_set.hydra_attributes.create(name: 'one', backend_type: 'string') }

    before { hydra_set.hydra_attributes.destroy(hydra_attr) }

    describe 'main object is persisted' do
      it 'should remove object from collection' do
        hydra_set.hydra_attributes.should_not include(hydra_attr)
      end

      it 'should unlink objects from relation table' do
        relation = find_relation_object(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attr.id)
        relation.should be_nil
      end
    end

    describe 'main object is new object' do
      let(:build_method) { :build }

      it 'should remove object from collection' do
        hydra_set.hydra_attributes.should_not include(hydra_attr)
      end
    end
  end
end