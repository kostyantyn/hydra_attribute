require 'spec_helper'

describe HydraAttribute::ActiveRecord do
  describe '.find' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string')
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer')
    end

    it 'should have hydra attributes' do
      product = Product.create(name: 'one', title: 'wow', code: 42)
      product = Product.find(product.id)
      product.name.should  == 'one'
      product.title.should == 'wow'
      product.code.should  == 42
    end
  end

  describe '.count' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string')
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer')
      Product.create(name: 'one', title: 'abc', code: 42)
      Product.create(name: 'two', title: 'qwe', code: 52)
    end

    it 'should correct count the number of records' do
      Product.count.should be(2)
    end
  end
end