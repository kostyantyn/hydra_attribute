require 'spec_helper'

describe HydraAttribute::ActiveRecord do
  describe '.create' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code',    backend_type: 'string',   default_value: nil) }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'info',    backend_type: 'string',   default_value: '') }
    let!(:attr3) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'total',   backend_type: 'integer',  default_value: 0) }
    let!(:attr4) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price',   backend_type: 'float',    default_value: 0) }
    let!(:attr5) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'active',  backend_type: 'boolean',  default_value: 0) }
    let!(:attr6) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'started', backend_type: 'datetime', default_value: '2013-01-01') }

    let(:product) { Product.find(Product.create(attributes).id) }

    describe 'without any attributes' do
      let(:attributes) { {} }

      it 'should have default values' do
        product.code.should be_nil
        product.info.should == ''
        product.total.should be(0)
        product.price.should == 0.0
        product.active.should be_false
        product.started.should == Time.utc('2013-01-01')
      end
    end

    describe 'with "code", "info" and "price" attributes' do
      let(:attributes) { {code: 'a', info: nil, price: nil} }

      it 'should save these attributes into database' do
        product.code.should == 'a'
        product.info.should be_nil
        product.total.should be(0)
        product.price.should == nil
        product.active.should be_false
        product.started.should == Time.utc('2013-01-01')
      end
    end

    describe 'with all attributes' do
      let(:attributes) { {code: 'a', info: 'b', total: 3, price: 4.3, active: true, started: Time.utc('2013-02-03')} }

      it 'should save all these attributes into database' do
        product.code.should == 'a'
        product.info.should == 'b'
        product.total.should == 3
        product.price.should == 4.3
        product.active.should be_true
        product.started.should == Time.utc('2013-02-03')
      end
    end

    describe 'with all attributes and hydra_set_id' do
      let(:hydra_set_id) { HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default').id }
      let(:attributes)   { {code: 'a', info: 'b', total: 3, price: 4.3, active: true, started: Time.utc('2013-02-03'), hydra_set_id: hydra_set_id} }

      before do
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr1.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr3.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr5.id)
      end

      let(:value) { ->(entity, attr) { ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_#{attr.backend_type}_#{entity.class.table_name} WHERE entity_id = #{entity.id} AND hydra_attribute_id = #{attr.id}") } }

      it 'should save only attributes from this hydra set' do
        value.(product, attr1).should == 'a'
        value.(product, attr2).should be_nil
        value.(product, attr3).to_i.should == 3
        value.(product, attr4).should be_nil
        ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.should include(value.(product, attr5))
        value.(product, attr6).should be_nil
      end
    end
  end

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