require 'spec_helper'

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