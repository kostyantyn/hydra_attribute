require 'spec_helper'

describe HydraAttribute::HydraAttribute do
  describe '.hydra_attributes_by_entity_type' do
    describe 'hydra_attributes table has several records' do
      let!(:attr_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr1', 'string')])  }
      let!(:attr_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr2', 'integer')]) }
      let!(:attr_id3) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Category', 'attr3', 'string')]) }

      it 'should return hydra_attributes which have the following entity_type' do
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Product').map(&:name).should =~ %w[attr1 attr2]
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Category').map(&:name).should =~ %w[attr3]
      end

      it 'should not return hydra_attribute which was removed in runtime' do
        HydraAttribute::HydraAttribute.find(attr_id1).destroy
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Product').map(&:name).should =~ %w[attr2]
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Category').map(&:name).should =~ %w[attr3]
      end

      it 'should not return hydra_attribute which entity_type was changed in runtime' do
        hydra_attribute = HydraAttribute::HydraAttribute.find(attr_id1)
        hydra_attribute.entity_type = 'Category'
        hydra_attribute.save

        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Product').map(&:name).should =~ %w[attr2]
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Category').map(&:name).should =~ %w[attr1 attr3]
      end
    end

    describe 'hydra_attributes table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Product').should == []
      end

      it 'should return hydra_attribute which was created in runtime' do
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Product').should == []
        hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr1', backend_type: 'string')
        HydraAttribute::HydraAttribute.hydra_attributes_by_entity_type('Product').should == [hydra_attribute]
      end
    end
  end

  describe '.hydra_attribute_ids_by_entity_type' do
    describe 'hydra_attributes table has several records' do
      let!(:attr_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr1', 'string')]).to_i  }
      let!(:attr_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr2', 'integer')]).to_i }
      let!(:attr_id3) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Category', 'attr3', 'string')]).to_i }

      it 'should return IDs by entity_type' do
        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Product').should  =~ [attr_id1, attr_id2]
        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Category').should =~ [attr_id3]
      end

      it 'should not return ID if model was removed in runtime' do
        HydraAttribute::HydraAttribute.find(attr_id1).destroy
        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Product').should  =~ [attr_id2]
        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Category').should =~ [attr_id3]
      end

      it 'should not return ID if entity_type was updated in runtime' do
        hydra_attribute = HydraAttribute::HydraAttribute.find(attr_id1)
        hydra_attribute.entity_type = 'Category'
        hydra_attribute.save

        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Product').should  =~ [attr_id2]
        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Category').should =~ [attr_id1, attr_id3]
      end
    end

    describe 'hydra_attributes table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Product').should == []
      end

      it 'should return IDs which were created in runtime' do
        a1 = HydraAttribute::HydraAttribute.create(entity_type: 'Product',  name: 'attr', backend_type: 'string')
        a2 = HydraAttribute::HydraAttribute.create(entity_type: 'Category', name: 'attr', backend_type: 'string')

        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Product').should  == [a1.id]
        HydraAttribute::HydraAttribute.hydra_attribute_ids_by_entity_type('Category').should == [a2.id]
      end
    end
  end

  describe '.hydra_attribute_names_by_entity_type' do
    describe 'hydra_attributes table has several records' do
      let!(:attr_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr1', 'string')])  }
      let!(:attr_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr2', 'integer')]) }
      let!(:attr_id3) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Category', 'attr3', 'string')]) }

      it 'should return names by entity_type' do
        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Product').should  =~ %w[attr1 attr2]
        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Category').should =~ %w[attr3]
      end

      it 'should not return name for model which was removed in runtime' do
        HydraAttribute::HydraAttribute.find(attr_id1).destroy
        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Product').should  =~ %w[attr2]
        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Category').should =~ %w[attr3]
      end

      it 'should not return name for model which entity_type was changed in runtime' do
        hydra_attribute = HydraAttribute::HydraAttribute.find(attr_id1)
        hydra_attribute.entity_type = 'Category'
        hydra_attribute.save

        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Product').should  =~ %w[attr2]
        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Category').should =~ %w[attr1 attr3]
      end
    end

    describe 'hydra_attributes table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Product').should == []
      end

      it 'should return names which where created in runtime' do
        HydraAttribute::HydraAttribute.create(entity_type: 'Product',  name: 'attr1', backend_type: 'string')
        HydraAttribute::HydraAttribute.create(entity_type: 'Category', name: 'attr2', backend_type: 'string')

        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Product').should  == %w[attr1]
        HydraAttribute::HydraAttribute.hydra_attribute_names_by_entity_type('Category').should == %w[attr2]
      end
    end
  end

  describe '#hydra_sets' do
    it 'should return blank array if model has not ID' do
      HydraAttribute::HydraAttribute.new.hydra_sets.should == []
    end

    it 'should return blank array if model has not any hydra_sets' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string')
      hydra_attribute.hydra_sets.should == []
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