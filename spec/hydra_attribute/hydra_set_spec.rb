require 'spec_helper'

describe HydraAttribute::HydraSet do
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
__END__
describe HydraAttribute::HydraSet do
  describe '#hydra_attributes=' do
    let!(:hydra_set) { Product.hydra_sets.create(name: 'Default') }

    it 'should clear entity cache if assign hydra attributes collection' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:clear_hydra_method_cache!)
      hydra_set.hydra_attributes = [hydra_attribute]
    end

    it 'should clear entity cache if assign blank collection' do
      hydra_set.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:clear_hydra_method_cache!)
      hydra_set.hydra_attributes = []
    end
  end
end