require 'spec_helper'

describe HydraAttribute::HydraAttribute do
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

__END__
describe HydraAttribute::HydraAttribute do
  describe '#hydra_sets=' do
    let!(:hydra_attribute) { Product.hydra_attributes.create(name: 'one', backend_type: 'string') }

    it 'should clear entity cache if assign hydra sets collection' do
      hydra_set = Product.hydra_sets.create(name: 'Default')
      Product.should_receive(:clear_hydra_method_cache!)
      hydra_attribute.hydra_sets = [hydra_set]
    end

    it 'should clear entity cache if assign blank collection' do
      hydra_attribute.hydra_sets.create(name: 'Default')
      Product.should_receive(:clear_hydra_method_cache!)
      hydra_attribute.hydra_sets = []
    end
  end
end