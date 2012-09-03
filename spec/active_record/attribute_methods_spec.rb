require 'spec_helper'

describe HydraAttribute::ActiveRecord::AttributeMethods do
  describe '::ClassMethods' do
    describe '#define_hydra_attribute_method' do
      it 'should throw MissingAttributeInHydraSetError if we call generated hydra attribute method which does not exist in hydra set' do
        Product.hydra_attributes.create(name: 'color', backend_type: 'string')
        hydra_set = Product.hydra_sets.create(name: 'Default')
        product   = Product.new(hydra_set_id: hydra_set.id)

        lambda do
          product.color
        end.should raise_error(HydraAttribute::MissingAttributeInHydraSetError, %(Hydra attribute "color" does not exist in hydra set "Default"))
      end
    end
  end
end