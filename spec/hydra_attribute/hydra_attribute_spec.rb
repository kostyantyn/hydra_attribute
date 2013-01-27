require 'spec_helper'

describe HydraAttribute::HydraAttribute do
  describe '#create' do
    it 'should add model to the cache' do
      HydraAttribute::HydraAttribute.model_identity_map.should be_empty
      model = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float')
      HydraAttribute::HydraAttribute.model_identity_map[model.id].should be(model)
    end
  end

  describe '#destroy' do
    it 'should remove model from the cache' do
      model = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float')
      HydraAttribute::HydraAttribute.model_identity_map[model.id].should be(model)

      model.destroy
      HydraAttribute::HydraAttribute.model_identity_map[model.id].should be_nil
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