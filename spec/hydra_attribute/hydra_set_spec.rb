require 'spec_helper'

describe HydraAttribute::HydraSet do
  describe '#hydra_attributes' do
    it 'should return blank array if model has not ID' do
      HydraAttribute::HydraSet.new.hydra_attributes.should be_blank
    end

    it 'should return blank array if model has not any hydra_attributes' do
      hydra_set = HydraAttribute::HydraSet.create(name: 'default', entity_type: 'Product')
      hydra_set.hydra_attributes.should be_blank
    end

    it 'should return array of hydra_attributes for the current hydra_set' do
      hydra_set1       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default1')
      hydra_set2       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default2')
      hydra_attribute1 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr1', backend_type: 'string')
      hydra_attribute2 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr2', backend_type: 'string')
      hydra_attribute3 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr3', backend_type: 'string')

      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set1.id, hydra_attribute_id: hydra_attribute1.id)
      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set1.id, hydra_attribute_id: hydra_attribute2.id)
      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set2.id, hydra_attribute_id: hydra_attribute3.id)

      hydra_set1.should have(2).hydra_attributes
      hydra_set2.should have(1).hydra_attributes

      hydra_set1.hydra_attributes.should include(hydra_attribute1)
      hydra_set1.hydra_attributes.should include(hydra_attribute2)
      hydra_set2.hydra_attributes.should include(hydra_attribute3)
    end
  end

  describe 'validations' do
    it 'should require entity_type' do
      hydra_set = HydraAttribute::HydraSet.new
      hydra_set.valid?
      hydra_set.errors.should include(:entity_type)

      hydra_set.entity_type = 'Product'
      hydra_set.valid?
      hydra_set.errors.should_not include(:entity_type)
    end

    it 'should require name' do
      hydra_set = HydraAttribute::HydraSet.new
      hydra_set.valid?
      hydra_set.errors.should include(:name)

      hydra_set.name = 'Default'
      hydra_set.valid?
      hydra_set.errors.should_not include(:name)
    end

    it 'should have unique name with entity_type' do
      HydraAttribute::HydraSet.create(name: 'Default', entity_type: 'Product').should be_persisted
      HydraAttribute::HydraSet.create(name: 'Default', entity_type: 'Product').should_not be_persisted
    end
  end
end