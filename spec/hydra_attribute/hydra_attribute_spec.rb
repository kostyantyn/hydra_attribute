require 'spec_helper'

describe HydraAttribute::HydraAttribute do
  describe '#hydra_sets' do
    it 'should return blank array if model has not ID' do
      HydraAttribute::HydraAttribute.new.hydra_sets.should be_blank
    end

    it 'should return blank array if model has not any hydra_sets' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string')
      hydra_attribute.hydra_sets.should be_blank
    end

    it 'should return array of hydra_sets for the current hydra_attribute' do
      hydra_attribute1 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr1', backend_type: 'string')
      hydra_attribute2 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr2', backend_type: 'string')
      hydra_set1       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default1')
      hydra_set2       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default2')
      hydra_set3       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default3')


      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set1.id, hydra_attribute_id: hydra_attribute1.id)
      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set2.id, hydra_attribute_id: hydra_attribute1.id)
      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set3.id, hydra_attribute_id: hydra_attribute2.id)

      hydra_attribute1.should have(2).hydra_sets
      hydra_attribute2.should have(1).hydra_sets

      hydra_attribute1.hydra_sets.should include(hydra_set1)
      hydra_attribute1.hydra_sets.should include(hydra_set2)
      hydra_attribute2.hydra_sets.should include(hydra_set3)
    end
  end

  describe 'validations' do
    it 'should require entity_type' do
      hydra_attribute = HydraAttribute::HydraAttribute.new
      hydra_attribute.valid?
      hydra_attribute.errors.should include(:entity_type)

      hydra_attribute.entity_type = 'Product'
      hydra_attribute.valid?
      hydra_attribute.errors.should_not include(:entity_type)
    end

    it 'should require name' do
      hydra_attribute = HydraAttribute::HydraAttribute.new
      hydra_attribute.valid?
      hydra_attribute.errors.should include(:name)

      hydra_attribute.name = 'price'
      hydra_attribute.valid?
      hydra_attribute.errors.should_not include(:price)
    end

    it 'should have a unique entity_type and name' do
      HydraAttribute::HydraAttribute.create(name: 'price', entity_type: 'Product', backend_type: 'float').should be_persisted
      HydraAttribute::HydraAttribute.create(name: 'price', entity_type: 'Product', backend_type: 'float').should_not be_persisted
    end

    it 'should require backend_type' do
      hydra_attribute = HydraAttribute::HydraAttribute.new
      hydra_attribute.valid?
      hydra_attribute.errors.should include(:backend_type)

      hydra_attribute.backend_type = 'integer'
      hydra_attribute.valid?
      hydra_attribute.errors.should_not include(:backend_type)
    end

    it 'should have a valid backend_type' do
      hydra_attribute = HydraAttribute::HydraAttribute.new(backend_type: 'fake')
      hydra_attribute.valid?
      hydra_attribute.errors.should include(:backend_type)

      HydraAttribute::SUPPORTED_BACKEND_TYPES.each do |backend_type|
        hydra_attribute.backend_type = backend_type
        hydra_attribute.valid?
        hydra_attribute.errors.should_not include(:backend_type)
      end
    end
  end

end