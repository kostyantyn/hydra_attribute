require 'spec_helper'

__END__
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

      it 'should not throw error when new sub class instance is created' do
        Product.hydra_attributes.create(name: 'color', backend_type: 'string')
        Product.reset_hydra_attribute_methods!

        sub_class = Class.new(Product)
        lambda do
          sub_class.new.color
        end.should_not raise_error
      end

      it 'should allow access to attributes from base model and its sub model' do
        Product.hydra_attributes.create(name: 'color', backend_type: 'string')
        Product.reset_hydra_attribute_methods!
        Product.send(:remove_instance_variable, :@generated_hydra_attribute_methods)

        sub_class = Class.new(Product)
        lambda do
          sub_class.new.color
          Product.new.color
        end.should_not raise_error
      end
    end
  end
end