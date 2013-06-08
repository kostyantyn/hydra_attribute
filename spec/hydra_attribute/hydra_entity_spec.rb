require 'spec_helper'

describe HydraAttribute::HydraEntity do
  describe '.hydra_attributes' do
    it 'should return all hydra attributes for the model' do
      Product.should have(0).hydra_attributes
      Category.should have(0).hydra_attributes

      HydraAttribute::HydraAttribute.create(entity_type: 'Product',  name: 'color', backend_type: 'string')
      HydraAttribute::HydraAttribute.create(entity_type: 'Product',  name: 'title', backend_type: 'string')
      HydraAttribute::HydraAttribute.create(entity_type: 'Category', name: 'price', backend_type: 'decimal')

      Product.should  have(2).hydra_attributes
      Category.should have(1).hydra_attributes

      Product.hydra_attributes.map(&:name).should  =~ %w[color title]
      Category.hydra_attributes.map(&:name).should =~ %w[price]
    end

    it 'should have a helper method for creating a hydra attribute for this model' do
      Product.hydra_attributes.create(name: 'height', backend_type: 'string')
      Product.hydra_attributes.create(name: 'weight', backend_type: 'string')
      Category.hydra_attributes.create(name: 'total', backend_type: 'decimal')

      Product.hydra_attributes.map(&:name).should  =~ %w[height weight]
      Category.hydra_attributes.map(&:name).should =~ %w[total]
    end
  end

  describe '.hydra_sets' do
    it 'should return all hydra sets for the model' do
      Product.should have(0).hydra_sets
      Category.should have(0).hydra_sets

      HydraAttribute::HydraSet.create(entity_type: 'Product',  name: 'one')
      HydraAttribute::HydraSet.create(entity_type: 'Product',  name: 'two')
      HydraAttribute::HydraSet.create(entity_type: 'Category', name: 'three')

      Product.should  have(2).hydra_sets
      Category.should have(1).hydra_sets

      Product.hydra_sets.map(&:name).should  =~ %w[one two]
      Category.hydra_sets.map(&:name).should =~ %w[three]
    end

    it 'should have a helper method for creating a hydra set for this model' do
      Product.hydra_sets.create(name: 'default1')
      Product.hydra_sets.create(name: 'default2')
      Category.hydra_sets.create(name: 'default3')

      Product.hydra_sets.map(&:name).should  =~ %w[default1 default2]
      Category.hydra_sets.map(&:name).should =~ %w[default3]
    end
  end

  describe '#hydra_attributes' do
    it 'should delegate the method to the hydra_attribute_association object' do
      product = Product.new
      product.hydra_attribute_association.should_receive(:hydra_attributes).once.and_return(name: :value)
      product.hydra_attributes.should == {name: :value}
    end
  end
end