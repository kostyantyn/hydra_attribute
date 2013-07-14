require 'spec_helper'

describe HydraAttribute::Model do
  describe '.first' do
    before do
      Product.hydra_attributes.create(name: 'yyy', backend_type: 'string')
      Product.hydra_attributes.create(name: 'aaa', backend_type: 'string')
      Product.hydra_attributes.create(name: 'zzz', backend_type: 'string')
    end

    it 'should return first created model' do
      HydraAttribute::HydraAttribute.first.name.should == 'yyy'
    end
  end

  describe '.last' do
    before do
      Product.hydra_attributes.create(name: 'yyy', backend_type: 'string')
      Product.hydra_attributes.create(name: 'aaa', backend_type: 'string')
      Product.hydra_attributes.create(name: 'bbb', backend_type: 'string')
    end

    it 'should return last created model' do
      HydraAttribute::HydraAttribute.last.name.should == 'bbb'
    end
  end
end