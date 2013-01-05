require 'spec_helper'

describe HydraAttribute::HydraValue do
  describe '.arel_tables' do
    it 'should return hash which holds arel tables for entity table and backend type' do
      arel_tables = HydraAttribute::HydraValue.arel_tables

      table = arel_tables['products']['string']
      table.name.should   == 'hydra_string_products'
      table.engine.should == ActiveRecord::Base

      table = arel_tables['entity_table']['backend_type']
      table.name.should   == 'hydra_backend_type_entity_table'
      table.engine.should == ActiveRecord::Base
    end

    it 'should cache result' do
      arel_tables = HydraAttribute::HydraValue.arel_tables

      table1 = arel_tables['product_table']['backend_type']
      table2 = arel_tables['product_table']['backend_type']
      table1.should be(table2)
    end
  end

  describe '#initialize' do
    it 'should raise error when :hydra_attribute_id is not passed to initialize' do
      lambda do
        HydraAttribute::HydraValue.new(Product.new)
      end.should raise_error(HydraAttribute::HydraValue::HydraAttributeIdIsMissedError, 'Key :hydra_attribute_id is missed')
    end

    it 'should not raise error when :hydra_attribute_id us passed' do
      lambda do
        HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: nil)
      end.should_not raise_error
    end
  end

  describe '#id' do
    it 'should return primary key for model' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, id: 12, hydra_attribute_id: 34)
      hydra_value.id.should be(12)
    end

    it 'should return nil if primary set is not specified' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 34)
      hydra_value.id.should be_nil
    end
  end

  describe '#id=' do
    it 'should set primary key for model' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 1)

      hydra_value.id = 23
      hydra_value.id.should be(23)

      hydra_value.id = 45
      hydra_value.id.should be(45)
    end
  end

  describe '#hydra_attribute_id' do
    it 'should return attribute ID which this model belongs to' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 23)
      hydra_value.hydra_attribute_id.should be(23)
    end
  end

  describe '#value' do
    it 'should return default value' do
      hydra_attribute = Product.hydra_attributes.create!(name: 'code', backend_type: 'string')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.value.should be_nil

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, value: 'abc')
      hydra_value.value.should == 'abc'
    end

    it 'should return type casted value' do
      hydra_attribute = Product.hydra_attributes.create!(name: 'qry', backend_type: 'integer')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, value: '12a')
      hydra_value.value.should == 12
    end
  end

  describe '#value=' do
    it 'should change current value' do
      hydra_attribute = Product.hydra_attributes.create!(name: 'code', backend_type: 'string')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, value: 'abc')
      hydra_value.value = 'www'
      hydra_value.value.should == 'www'
    end

    it 'should type cast value before assign it' do
      hydra_attribute = Product.hydra_attributes.create!(name: 'price', backend_type: 'float')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)

      hydra_value.value = '2.57a'
      hydra_value.value.should == 2.57

      hydra_value.value = 'a'
      hydra_value.value.should == 0.0
    end
  end

  describe '#value?' do
    let(:hydra_attribute) { Product.hydra_attributes.create(name: 'price', backend_type: backend_type) }
    let(:hydra_value)     { HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id) }

    describe 'integer attribute' do
      let(:backend_type) { 'integer' }

      it 'should be true for 1' do
        hydra_value.value = 1
        hydra_value.value?.should be_true
      end

      it 'should be false for 0' do
        hydra_value.value = 0
        hydra_value.value?.should be_false
      end

      it 'should be false for nil' do
        hydra_value.value = nil
        hydra_value.value?.should be_false
      end
    end

    describe 'string attribute' do
      let(:backend_type) { 'string' }

      it 'should be true for "abc"' do
        hydra_value.value = 'abc'
        hydra_value.value?.should be_true
      end

      it 'should be false for ""' do
        hydra_value.value = ''
        hydra_value.value?.should be_false
      end

      it 'should be false for nil' do
        hydra_value.value = nil
        hydra_value.value?.should be_false
      end
    end
  end

  describe '#value_before_type_cast' do
    let(:hydra_attribute) { Product.hydra_attributes.create!(name: 'price', backend_type: 'float') }
    let(:hydra_value)     { HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id) }

    it 'should return not type casted value' do
      hydra_value.value = '2.0'
      hydra_value.value_before_type_cast.should == '2.0'

      hydra_value.value = 'aaa'
      hydra_value.value_before_type_cast.should == 'aaa'
    end
  end

  describe '#hydra_attribute' do
    it 'should return hydra attribute model' do
      hydra_attribute = Product.hydra_attributes.create!(name: 'price', backend_type: 'float')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.hydra_attribute.should == hydra_attribute
    end
  end

  describe '#name' do
    it 'should return hydra attribute name' do
      hydra_attribute = Product.hydra_attributes.create!(name: 'price', backend_type: 'float')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.name.should == hydra_attribute.name
    end
  end

  describe '#backend_type' do
    it 'should return hydra attribute backend type' do
      hydra_attribute = Product.hydra_attributes.create!(name: 'price', backend_type: 'float')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.backend_type.should == hydra_attribute.backend_type
    end
  end

  describe '#persisted?' do
    it 'should return true if model has ID' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 1, id: 2)
      hydra_value.should be_persisted

      hydra_value.id = 5
      hydra_value.should be_persisted

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 1)
      hydra_value.id = 5
      hydra_value.should be_persisted
    end

    it 'should return false unless model has ID' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 1)
      hydra_value.should_not be_persisted

      hydra_value.id = nil
      hydra_value.should_not be_persisted

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 1, id: 5)
      hydra_value.id = nil
      hydra_value.should_not be_persisted
    end
  end

  describe '#save' do
    it 'should raise error if entity model is not persisted' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 1)
      lambda do
        hydra_value.save
      end.should raise_error(HydraAttribute::HydraValue::EntityModelIsNotPersistedError, 'HydraValue model cannot be saved is entity model is not persisted')
    end

    it 'should not save value if model is not changed' do
      hydra_value = HydraAttribute::HydraValue.new(product, hydra_attribute_id: hydra_attribute.id)

      conn  = product.connection
      count = lambda { conn.select_value('SELECT COUNT(*) FROM hydra_float_products') }
      lambda do
        hydra_value.save
      end.should_not change(&count)
    end

    let(:product)         { Product.create! }
    let(:hydra_attribute) { Product.hydra_attributes.create!(name: 'price', backend_type: 'float') }

    describe 'new hydra value' do
      it 'should create new hydra value record in database' do
        hydra_value = HydraAttribute::HydraValue.new(product, hydra_attribute_id: hydra_attribute.id)

        conn  = product.connection
        count = lambda { conn.select_value('SELECT COUNT(*) FROM hydra_float_products') }
        lambda do
          hydra_value.value = 2.50
          hydra_value.save
          hydra_value.id.should_not be_nil

          result = conn.select_one("SELECT * FROM hydra_float_products WHERE id=#{hydra_value.id}")
          result['hydra_attribute_id'].should == hydra_attribute.id
          result['entity_id'].should          == product.id
          result['value'].should              == 2.50
        end.should change(&count).by(1)
      end
    end

    describe 'existed hydra value' do
      it 'should update hydra value in database' do
        hydra_value = HydraAttribute::HydraValue.new(product, hydra_attribute_id: hydra_attribute.id)
        hydra_value.value = 2.50
        hydra_value.save

        conn  = product.connection
        count = lambda { conn.select_value('SELECT COUNT(*) FROM hydra_float_products') }
        lambda do
          hydra_value.value = 5.50
          hydra_value.save

          result = conn.select_one("SELECT * FROM hydra_float_products WHERE id=#{hydra_value.id}")
          result['hydra_attribute_id'].should == hydra_attribute.id
          result['entity_id'].should          == product.id
          result['value'].should              == 5.50
        end.should_not change(&count)
      end
    end
  end

  describe 'value methods' do
    it 'should respond to dirty methods' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: 1)
      hydra_value.should respond_to(:value_changed?)
      hydra_value.should respond_to(:value_change)
      hydra_value.should respond_to(:value_will_change!)
      hydra_value.should respond_to(:value_was)
      hydra_value.should respond_to(:reset_value!)
    end
  end
end