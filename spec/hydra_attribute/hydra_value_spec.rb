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

  describe '.connection' do
    it 'should return the database connection' do
      HydraAttribute::HydraValue.connection.should be_a_kind_of(ActiveRecord::ConnectionAdapters::AbstractAdapter)
    end
  end

  describe '.column' do
    it 'should return a column by hydra_attribute_id' do
      float   = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a1', backend_type: 'float',  default_value: 2.5)
      string  = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a2', backend_type: 'string', default_value: 'abc')
      integer = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a3', backend_type: 'integer')

      float_column = HydraAttribute::HydraValue.column(float.id)
      float_column.should be_a_kind_of(::ActiveRecord::ConnectionAdapters::Column)
      float_column.name.should     == 'a1'
      float_column.default.should  == 2.5
      float_column.sql_type.should == 'float'

      string_column = HydraAttribute::HydraValue.column(string.id)
      string_column.should be_a_kind_of(::ActiveRecord::ConnectionAdapters::Column)
      string_column.name.should     == 'a2'
      string_column.default.should  == 'abc'
      string_column.sql_type.should == 'string'

      integer_column = HydraAttribute::HydraValue.column(integer.id)
      integer_column.should be_a_kind_of(::ActiveRecord::ConnectionAdapters::Column)
      integer_column.name.should     == 'a3'
      integer_column.default.should be_nil
      integer_column.sql_type.should == 'integer'
    end
  end

  describe '#initialize' do
    it 'should raise error when :hydra_attribute_id is not passed to initialize' do
      lambda do
        HydraAttribute::HydraValue.new(Product.new)
      end.should raise_error(HydraAttribute::HydraValue::HydraAttributeIdIsMissedError, 'Key :hydra_attribute_id is missed')
    end

    it 'should not raise error when :hydra_attribute_id is passed' do
      attr = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float')

      lambda do
        HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: attr.id)
      end.should_not raise_error
    end
  end

  describe '#column' do
    let(:hydra_value)        { HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute_id) }
    let(:hydra_attribute_id) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: backend_type).id }

    describe 'for string hydra_attribute' do
      let(:backend_type) { 'string' }

      it 'should return string virtual column' do
        hydra_value.column.should be_a_kind_of(::ActiveRecord::ConnectionAdapters::Column)
        hydra_value.column.sql_type.should == 'string'
      end
    end

    describe 'for integer hydra attribute' do
      let(:backend_type) { 'integer' }

      it 'should return integer virtual column' do
        hydra_value.column.should be_a_kind_of(::ActiveRecord::ConnectionAdapters::Column)
        hydra_value.column.sql_type.should == 'integer'
      end
    end
  end

  describe '#id' do
    let(:hydra_attribute) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float') }

    it 'should return model ID' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, id: 2)
      hydra_value.id.should be(2)

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.id.should be_nil
    end
  end

  describe '#value' do
    it 'should return default value' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'string', default_value: 'abc')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.value.should == 'abc'

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, value: 'qwerty')
      hydra_value.value.should == 'qwerty'
    end

    it 'should return type casted value' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, value: '12a')
      hydra_value.value.should == 12
    end
  end

  describe '#value=' do
    it 'should change current value' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'string')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, value: 'abc')
      hydra_value.value = 'www'
      hydra_value.value.should == 'www'
    end

    it 'should type cast value before assign it' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)

      hydra_value.value = '2.57a'
      hydra_value.value.should == 2.57

      hydra_value.value = 'a'
      hydra_value.value.should == 0.0
    end
  end

  describe '#value?' do
    let(:hydra_attribute) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: backend_type) }
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
    let(:hydra_attribute) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float') }
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
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float')

      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.hydra_attribute.should be(hydra_attribute)
    end
  end

  describe '#persisted?' do
    let(:hydra_attribute) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float') }

    it 'should return true if model has ID' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id, id: 2)
      hydra_value.should be_persisted
    end

    it 'should return false unless model has ID' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.should_not be_persisted
    end
  end

  describe '#save' do
    let(:product)         { Product.create! }
    let(:hydra_attribute) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float', default_value: 0.1) }

    it 'should raise an error if entity model is not persisted' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      lambda do
        hydra_value.save
      end.should raise_error(HydraAttribute::HydraValue::EntityModelIsNotPersistedError, 'HydraValue model cannot be saved is entity model is not persisted')
    end

    describe 'create' do
      it 'should create model with default value' do
        hydra_value = HydraAttribute::HydraValue.new(product, hydra_attribute_id: hydra_attribute.id)
        hydra_value.save

        value = product.class.connection.select_value("SELECT value FROM hydra_float_products WHERE entity_id=#{product.id} AND hydra_attribute_id=#{hydra_attribute.id}")
        value.to_f.should == 0.1
      end

      it 'should create model with changed value' do
        hydra_value = HydraAttribute::HydraValue.new(product, hydra_attribute_id: hydra_attribute.id)
        hydra_value.value = 2.5
        hydra_value.save

        value = product.class.connection.select_value("SELECT value FROM hydra_float_products WHERE id=#{hydra_value.id}")
        value.to_f.should == 2.5
      end
    end

    describe 'update' do
      it 'should update hydra value in database' do
        hydra_value = HydraAttribute::HydraValue.new(product, hydra_attribute_id: hydra_attribute.id)
        hydra_value.value = 2.5
        hydra_value.save

        hydra_value.value = 5.5
        hydra_value.save

        value = product.class.connection.select_value("SELECT value FROM hydra_float_products WHERE id=#{hydra_value.id}")
        value.to_f.should == 5.5
      end
    end
  end

  describe 'value methods' do
    let(:hydra_attribute) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'string') }

    it 'should respond to dirty methods' do
      hydra_value = HydraAttribute::HydraValue.new(Product.new, hydra_attribute_id: hydra_attribute.id)
      hydra_value.should respond_to(:value_changed?)
      hydra_value.should respond_to(:value_change)
      hydra_value.should respond_to(:value_will_change!)
      hydra_value.should respond_to(:value_was)
      hydra_value.should respond_to(:reset_value!)
    end
  end
end
