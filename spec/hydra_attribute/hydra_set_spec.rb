require 'spec_helper'

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