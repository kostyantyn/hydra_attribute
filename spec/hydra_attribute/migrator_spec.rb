require 'spec_helper'

describe HydraAttribute::Migrator do
  let(:connection)     { ActiveRecord::Base.connection }
  let(:migrator)       { HydraAttribute::Migrator.new(connection) }
  let(:backend_tables) { ->(entity){ HydraAttribute::SUPPORTED_BACKEND_TYPES.map { |type| "hydra_#{type}_#{entity}" }} }

  describe '#create' do
    after { migrator.drop(:wheels) }

    before do
      migrator.create :wheels do |t|
        t.string :name
        t.timestamps
      end
    end

    describe 'entity' do
      let(:columns) { connection.columns(:wheels) }

      it 'should have the necessary columns' do
        columns.map(&:name).should =~ %w[id hydra_set_id name created_at updated_at]
      end

      it 'should have a correct column types' do
        column = columns.find { |c| c.name == 'hydra_set_id' }
        column.null.should be_true
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'integer'
        when 'mysql'      then column.sql_type.should == 'int(11)'
        when 'sqlite'     then column.sql_type.should == 'integer'
        else raise 'Unknown database'
        end
      end

      it 'should have a correct indexes' do
        index = connection.indexes(:wheels).find { |i| i.name == 'wheels_hydra_set_id_idx' }
        index.unique.should be_false
        index.columns.should == %w[hydra_set_id]
      end
    end

    describe 'hydra_attributes' do
      let(:columns) { connection.columns(:hydra_attributes) }

      it 'should have the necessary columns' do
        columns.map(&:name).should =~ %w[id entity_type name backend_type default_value white_list created_at updated_at]
      end

      it 'should have a correct column types' do
        column = columns.find { |c| c.name == 'entity_type' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'character varying(32)' : 'varchar(32)')
        column.null.should be_false

        column = columns.find { |c| c.name == 'name' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'character varying(32)' : 'varchar(32)')
        column.null.should be_false

        column = columns.find { |c| c.name == 'backend_type' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'character varying(16)' : 'varchar(16)')
        column.null.should be_false

        column = columns.find { |c| c.name == 'default_value' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'character varying(255)' : 'varchar(255)')
        column.null.should be_true

        column = columns.find { |c| c.name == 'white_list' }
        column.null.should be_false
        column.default.should be_false
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'boolean'
        when 'mysql'      then column.sql_type.should == 'tinyint(1)'
        when 'sqlite'     then column.sql_type.should == 'boolean'
        else raise 'Unknown database'
        end

        column = columns.find { |c| c.name == 'created_at' }
        column.null.should be_false
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'timestamp without time zone'
        when 'mysql'      then column.sql_type.should == 'datetime'
        when 'sqlite'     then column.sql_type.should == 'datetime'
        else raise 'Unknown database'
        end

        column = columns.find { |c| c.name == 'updated_at' }
        column.null.should be_false
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'timestamp without time zone'
        when 'mysql'      then column.sql_type.should == 'datetime'
        when 'sqlite'     then column.sql_type.should == 'datetime'
        else raise 'Unknown database'
        end
      end

      it 'should have a correct indexes' do
        connection.indexes(:hydra_attributes).should have(1).indexes
        connection.indexes(:hydra_attributes)[0].name.should   == 'hydra_attributes_idx'
        connection.indexes(:hydra_attributes)[0].unique.should be_true
        connection.indexes(:hydra_attributes)[0].columns.should == %w[entity_type name]
      end
    end

    describe 'hydra_sets' do
      let(:columns) { connection.columns(:hydra_sets) }

      it 'should have the necessary columns' do
        columns.map(&:name).should =~ %w[id entity_type name created_at updated_at]
      end

      it 'should have a correct column types' do
        column = columns.find { |c| c.name == 'entity_type' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'character varying(32)' : 'varchar(32)')
        column.null.should be_false

        column = columns.find { |c| c.name == 'name' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'character varying(32)' : 'varchar(32)')
        column.null.should be_false

        column = columns.find { |c| c.name == 'created_at' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'timestamp without time zone' : 'datetime')
        column.null.should be_false

        column = columns.find { |c| c.name == 'updated_at' }
        column.sql_type.should == (ENV['DB'] == 'postgresql' ? 'timestamp without time zone' : 'datetime')
        column.null.should be_false
      end

      it 'should have a correct indexes' do
        connection.indexes(:hydra_sets).should have(1).indexes
        connection.indexes(:hydra_sets)[0].name.should   == 'hydra_sets_idx'
        connection.indexes(:hydra_sets)[0].unique.should be_true
        connection.indexes(:hydra_sets)[0].columns.should == %w[entity_type name]
      end
    end

    describe 'hydra_attribute_sets' do
      let(:columns) { connection.columns(:hydra_attribute_sets) }

      it 'should have the necessary columns' do
        columns.map(&:name).should =~ %w[id hydra_attribute_id hydra_set_id created_at updated_at]
      end

      it 'should have a correct column types' do
        column = columns.find { |c| c.name == 'hydra_attribute_id' }
        column.null.should be_false
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'integer'
        when 'mysql'      then column.sql_type.should == 'int(11)'
        when 'sqlite'     then column.sql_type.should == 'integer'
        else raise 'Unknown database'
        end

        column = columns.find { |c| c.name == 'hydra_set_id' }
        column.null.should be_false
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'integer'
        when 'mysql'      then column.sql_type.should == 'int(11)'
        when 'sqlite'     then column.sql_type.should == 'integer'
        else raise 'Unknown database'
        end

        column = columns.find { |c| c.name == 'created_at' }
        column.null.should be_false
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'timestamp without time zone'
        when 'mysql'      then column.sql_type.should == 'datetime'
        when 'sqlite'     then column.sql_type.should == 'datetime'
        else raise 'Unknown database'
        end

        column = columns.find { |c| c.name == 'updated_at' }
        column.null.should be_false
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'timestamp without time zone'
        when 'mysql'      then column.sql_type.should == 'datetime'
        when 'sqlite'     then column.sql_type.should == 'datetime'
        else raise 'Unknown database'
        end
      end

      it 'should have a correct indexes' do
        connection.indexes(:hydra_attribute_sets).should have(1).indexes
        connection.indexes(:hydra_attribute_sets)[0].name.should    == 'hydra_attribute_sets_idx'
        connection.indexes(:hydra_attribute_sets)[0].unique.should  be_true
        connection.indexes(:hydra_attribute_sets)[0].columns.should == %w[hydra_attribute_id hydra_set_id]
      end
    end

    describe 'values' do
      it 'should have the following value tables' do
        connection.table_exists?('hydra_string_wheels').should   be_true
        connection.table_exists?('hydra_text_wheels').should     be_true
        connection.table_exists?('hydra_float_wheels').should    be_true
        connection.table_exists?('hydra_decimal_wheels').should  be_true
        connection.table_exists?('hydra_boolean_wheels').should  be_true
        connection.table_exists?('hydra_datetime_wheels').should be_true
      end

      it 'should have the correct column types' do
        %w[hydra_string_wheels hydra_text_wheels hydra_float_wheels hydra_boolean_wheels hydra_datetime_wheels].each do |table|
          column = connection.columns(table).find { |c| c.name == 'entity_id' }
          column.null.should be_false
          case ENV['DB']
          when 'postgresql' then column.sql_type.should == 'integer'
          when 'mysql'      then column.sql_type.should == 'int(11)'
          when 'sqlite'     then column.sql_type.should == 'integer'
          else raise 'Unknown database'
          end

          column = connection.columns(table).find { |c| c.name == 'hydra_attribute_id' }
          column.null.should be_false
          case ENV['DB']
          when 'postgresql' then column.sql_type.should == 'integer'
          when 'mysql'      then column.sql_type.should == 'int(11)'
          when 'sqlite'     then column.sql_type.should == 'integer'
          else raise 'Unknown database'
          end

          column = connection.columns(table).find { |c| c.name == 'created_at' }
          column.null.should be_false
          case ENV['DB']
          when 'postgresql' then column.sql_type.should == 'timestamp without time zone'
          when 'mysql'      then column.sql_type.should == 'datetime'
          when 'sqlite'     then column.sql_type.should == 'datetime'
          else raise 'Unknown database'
          end

          column = connection.columns(table).find { |c| c.name == 'updated_at' }
          column.null.should be_false
          case ENV['DB']
          when 'postgresql' then column.sql_type.should == 'timestamp without time zone'
          when 'mysql'      then column.sql_type.should == 'datetime'
          when 'sqlite'     then column.sql_type.should == 'datetime'
          else raise 'Unknown database'
          end
        end

        column = connection.columns('hydra_string_wheels').find { |c| c.name == 'value' }
        column.null.should be_true
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'character varying(255)'
        when 'mysql'      then column.sql_type.should == 'varchar(255)'
        when 'sqlite'     then column.sql_type.should == 'varchar(255)'
        else raise 'Unknown database'
        end

        column = connection.columns('hydra_text_wheels').find { |c| c.name == 'value' }
        column.null.should be_true
        column.sql_type.should == 'text'

        column = connection.columns('hydra_integer_wheels').find { |c| c.name == 'value' }
        column.null.should be_true
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'integer'
        when 'mysql'      then column.sql_type.should == 'int(11)'
        when 'sqlite'     then column.sql_type.should == 'integer'
        else raise 'Unknown database'
        end

        column = connection.columns('hydra_float_wheels').find { |c| c.name == 'value' }
        column.null.should be_true
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'double precision'
        when 'mysql'      then column.sql_type.should == 'float'
        when 'sqlite'     then column.sql_type.should == 'float'
        else raise 'Unknown database'
        end

        column = connection.columns('hydra_decimal_wheels').find { |c| c.name == 'value' }
        column.null.should      be_true
        column.precision.should be(10)
        column.scale.should     be(4)
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'numeric(10,4)'
        when 'mysql'      then column.sql_type.should == 'decimal(10,4)'
        when 'sqlite'     then column.sql_type.should == 'decimal(10,4)'
        else raise 'Unknown database'
        end

        column = connection.columns('hydra_boolean_wheels').find { |c| c.name == 'value' }
        column.null.should be_true
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'boolean'
        when 'mysql'      then column.sql_type.should == 'tinyint(1)'
        when 'sqlite'     then column.sql_type.should == 'boolean'
        else raise 'Unknown database'
        end

        column = connection.columns('hydra_datetime_wheels').find { |c| c.name == 'value' }
        column.null.should be_true
        case ENV['DB']
        when 'postgresql' then column.sql_type.should == 'timestamp without time zone'
        when 'mysql'      then column.sql_type.should == 'datetime'
        when 'sqlite'     then column.sql_type.should == 'datetime'
        else raise 'Unknown database'
        end
      end

      it 'should have a correct indexes' do
        connection.indexes(:hydra_string_wheels).should have(1).indexes
        connection.indexes(:hydra_string_wheels)[0].name.should    == 'hydra_string_wheels_idx'
        connection.indexes(:hydra_string_wheels)[0].unique.should  be_true
        connection.indexes(:hydra_string_wheels)[0].columns.should == %w[entity_id hydra_attribute_id]

        connection.indexes(:hydra_text_wheels).should have(1).indexes
        connection.indexes(:hydra_text_wheels)[0].name.should    == 'hydra_text_wheels_idx'
        connection.indexes(:hydra_text_wheels)[0].unique.should  be_true
        connection.indexes(:hydra_text_wheels)[0].columns.should == %w[entity_id hydra_attribute_id]

        connection.indexes(:hydra_integer_wheels).should have(1).indexes
        connection.indexes(:hydra_integer_wheels)[0].name.should    == 'hydra_integer_wheels_idx'
        connection.indexes(:hydra_integer_wheels)[0].unique.should  be_true
        connection.indexes(:hydra_integer_wheels)[0].columns.should == %w[entity_id hydra_attribute_id]

        connection.indexes(:hydra_float_wheels).should have(1).indexes
        connection.indexes(:hydra_float_wheels)[0].name.should    == 'hydra_float_wheels_idx'
        connection.indexes(:hydra_float_wheels)[0].unique.should  be_true
        connection.indexes(:hydra_float_wheels)[0].columns.should == %w[entity_id hydra_attribute_id]

        connection.indexes(:hydra_decimal_wheels).should have(1).indexes
        connection.indexes(:hydra_decimal_wheels)[0].name.should    == 'hydra_decimal_wheels_idx'
        connection.indexes(:hydra_decimal_wheels)[0].unique.should  be_true
        connection.indexes(:hydra_decimal_wheels)[0].columns.should == %w[entity_id hydra_attribute_id]

        connection.indexes(:hydra_boolean_wheels).should have(1).indexes
        connection.indexes(:hydra_boolean_wheels)[0].name.should    == 'hydra_boolean_wheels_idx'
        connection.indexes(:hydra_boolean_wheels)[0].unique.should  be_true
        connection.indexes(:hydra_boolean_wheels)[0].columns.should == %w[entity_id hydra_attribute_id]

        connection.indexes(:hydra_datetime_wheels).should have(1).indexes
        connection.indexes(:hydra_datetime_wheels)[0].name.should    == 'hydra_datetime_wheels_idx'
        connection.indexes(:hydra_datetime_wheels)[0].unique.should  be_true
        connection.indexes(:hydra_datetime_wheels)[0].columns.should == %w[entity_id hydra_attribute_id]
      end
    end
  end

  describe '#drop' do
    it 'should drop entity and hydra tables' do
      migrator.create :wheels
      connection.table_exists?(:wheels).should                be_true
      connection.table_exists?(:hydra_string_wheels).should   be_true
      connection.table_exists?(:hydra_text_wheels).should     be_true
      connection.table_exists?(:hydra_integer_wheels).should  be_true
      connection.table_exists?(:hydra_float_wheels).should    be_true
      connection.table_exists?(:hydra_boolean_wheels).should  be_true
      connection.table_exists?(:hydra_datetime_wheels).should be_true

      migrator.drop :wheels
      connection.table_exists?(:wheels).should                be_false
      connection.table_exists?(:hydra_string_wheels).should   be_false
      connection.table_exists?(:hydra_text_wheels).should     be_false
      connection.table_exists?(:hydra_integer_wheels).should  be_false
      connection.table_exists?(:hydra_float_wheels).should    be_false
      connection.table_exists?(:hydra_boolean_wheels).should  be_false
      connection.table_exists?(:hydra_datetime_wheels).should be_false
    end
  end

  describe '#migrate' do
    before { connection.create_table :wheels }
    after  { connection.drop_table :wheels   }

    it 'should create hydra tables for entity' do
      connection.table_exists?(:wheels).should                be_true
      connection.table_exists?(:hydra_string_wheels).should   be_false
      connection.table_exists?(:hydra_text_wheels).should     be_false
      connection.table_exists?(:hydra_integer_wheels).should  be_false
      connection.table_exists?(:hydra_float_wheels).should    be_false
      connection.table_exists?(:hydra_boolean_wheels).should  be_false
      connection.table_exists?(:hydra_datetime_wheels).should be_false

      migrator.migrate :wheels
      connection.table_exists?(:wheels).should                be_true
      connection.table_exists?(:hydra_string_wheels).should   be_true
      connection.table_exists?(:hydra_text_wheels).should     be_true
      connection.table_exists?(:hydra_integer_wheels).should  be_true
      connection.table_exists?(:hydra_float_wheels).should    be_true
      connection.table_exists?(:hydra_boolean_wheels).should  be_true
      connection.table_exists?(:hydra_datetime_wheels).should be_true

      migrator.rollback :wheels
    end
  end

  describe '#rollback' do
    before { connection.create_table :wheels }
    after  { connection.drop_table :wheels   }

    it 'should drop hydra tables for entity' do
      migrator.migrate :wheels
      connection.table_exists?(:wheels).should                be_true
      connection.table_exists?(:hydra_string_wheels).should   be_true
      connection.table_exists?(:hydra_text_wheels).should     be_true
      connection.table_exists?(:hydra_integer_wheels).should  be_true
      connection.table_exists?(:hydra_float_wheels).should    be_true
      connection.table_exists?(:hydra_boolean_wheels).should  be_true
      connection.table_exists?(:hydra_datetime_wheels).should be_true

      migrator.rollback :wheels
      connection.table_exists?(:wheels).should                be_true
      connection.table_exists?(:hydra_string_wheels).should   be_false
      connection.table_exists?(:hydra_text_wheels).should     be_false
      connection.table_exists?(:hydra_integer_wheels).should  be_false
      connection.table_exists?(:hydra_float_wheels).should    be_false
      connection.table_exists?(:hydra_boolean_wheels).should  be_false
      connection.table_exists?(:hydra_datetime_wheels).should be_false
    end
  end
end