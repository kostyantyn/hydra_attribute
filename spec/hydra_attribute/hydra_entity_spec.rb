require 'spec_helper'

describe HydraAttribute::HydraEntity do
  describe '#save' do
    let!(:attr_id) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'string', default_value: 'abc').id.to_i }

    describe 'new model' do
      let(:product) { Product.new }

      it 'should save with default attribute values' do
        product.save
        value = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id}")
        value.should == 'abc'
      end

      it 'should save changed attribute value' do
        product.code = 'qwe'
        product.save
        value = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id}")
        value.should == 'qwe'
      end

      it 'should save only attributes which are belong to hydra set' do
        attr_id2 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'color', backend_type: 'string').id
        set_id   = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: set_id, hydra_attribute_id: attr_id2)

        product.code  = 'qwerty'
        product.color = 'green'
        product.hydra_set_id = set_id
        product.save

        attr1 = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id}")
        attr1.should be_nil

        attr2 = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id2}")
        attr2.should == 'green'
      end
    end

    describe 'persisted model' do
      let(:product) { Product.create }

      it 'should not touch entity if hydra attributes were not changed' do
        updated_at = product.updated_at
        product.save
        product.updated_at.should == updated_at
      end

      it 'should touch entity if hydra attributes were changed' do
        updated_at = product.updated_at
        product.code = 'qwe'
        product.save
        product.updated_at.should > updated_at
      end
    end
  end

  describe '#destroy' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string') }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer') }

    let(:find_query) { ->(entity_id, attr) { "SELECT value FROM hydra_#{attr.backend_type}_products WHERE entity_id = #{entity_id} AND hydra_attribute_id = #{attr.id}" } }
    let(:find_value) { ->(entity_id, attr) { ::ActiveRecord::Base.connection.select_value(find_query.(entity_id, attr)) } }

    it 'should destroy all saved attributes for current entity' do
      product1 = Product.create(title: 'abc', code: 42)
      product2 = Product.create(title: 'qwe', code: 55)

      find_value.(product1.id, attr1).should      == 'abc'
      find_value.(product1.id, attr2).to_i.should == 42
      find_value.(product2.id, attr1).should      == 'qwe'
      find_value.(product2.id, attr2).to_i.should == 55
      product1.destroy
      find_value.(product1.id, attr1).should be_nil
      find_value.(product1.id, attr2).should be_nil
      find_value.(product2.id, attr1).should      == 'qwe'
      find_value.(product2.id, attr2).to_i.should == 55
    end
  end
end