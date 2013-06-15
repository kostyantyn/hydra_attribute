require 'spec_helper'

describe HydraAttribute::ActiveRecord::AttributeMethods do
  describe '#read_attribute' do
    before do
      Product.hydra_attributes.create(name: 'code',  backend_type: 'string',  default_value: 'abc')
    end

    let(:product) { Product.new }

    it 'should return value of static attribute' do
      product.name = 'one'
      product.read_attribute(:name).should == 'one'
    end

    it 'should return default hydra attribute value' do
      product.read_attribute(:code).should == 'abc'
    end

    it 'should return the value of hydra attribute' do
      product.code = 'second'
      product.read_attribute(:code).should == 'second'
    end

    it 'should return nil for unknown attribute' do
      product.read_attribute(:unknown).should be_nil
    end

    it 'should return nil if hydra attribute does not exist in hydra set' do
      product.hydra_set_id = Product.hydra_sets.create(name: 'default').id
      product.read_attribute(:name).should be_nil
    end
  end
end