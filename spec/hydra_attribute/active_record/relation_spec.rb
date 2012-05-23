require 'spec_helper'

describe HydraAttribute::ActiveRecord::Relation do
  def record_class(loaded_associations = false)
    Class.new do

      @hydra_attributes = {string: [:code]}
      define_singleton_method :hydra_attribute_types do
        [:string]
      end

      define_singleton_method :hydra_attribute_names do
        [:code]
      end

      define_singleton_method :hydra_attributes do
        @hydra_attributes
      end

      define_method :association do |_|
        Class.new do
          define_singleton_method :loaded? do
            loaded_associations
          end
        end
      end
    end
  end

  def relation_function(records)
    Module.new do
      define_method HydraAttribute.config.relation_execute_method do
        records
      end

      define_method :klass do
        records.first.class
      end

      define_method :where do |*|
        self
      end
    end
  end

  let(:records)  { [record_class.new] }
  let(:ancestor) { relation_function(records) }
  let(:klass)    { Class.new.extend(ancestor).extend(HydraAttribute::ActiveRecord::Relation) }

  describe "##{HydraAttribute.config.relation_execute_method}" do
    describe 'parent method return one record' do
      it 'should return one record' do
        klass.send(HydraAttribute.config.relation_execute_method).should have(1).record
      end
    end

    describe 'parent method returns two records' do
      let(:records) { [record_class(loaded_associations).new, record_class(loaded_associations).new] }

      describe 'association models are already loaded' do
        let(:loaded_associations) { true }

        it 'should return two record' do
          klass.send(HydraAttribute.config.relation_execute_method).should have(2).records
        end
      end

      describe 'association models are not yet loaded' do
        let(:loaded_associations) { false }

        before do
          ::ActiveRecord::Associations::Preloader.should_receive(:new).with(records, :hydra_string_attributes).and_return(mock(run: records))
        end

        it 'should return two record' do
          klass.send(HydraAttribute.config.relation_execute_method).should have(2).records
        end
      end
    end
  end

  # TODO should not add save join twice
  # Model.where(name: [1,2]).where(name: [2, 3])
  describe '#where' do
    let(:ancestor) do
      m = relation_function(records)
      m.class_eval do
        attr_writer :where_values

        def where_values
          @where_values ||= []
        end

        alias_method :joins_values,  :where_values
        alias_method :joins_values=, :where_values=

        define_method :where do |opts, *rest|
          relation = clone
          relation.where_values += ["opts: #{opts.inspect} - rest: #{rest.inspect}"]
          relation
        end
      end
      m
    end

    before do
      klass.class_eval do
        class << self
          define_method :build_hydra_joins_values do |name, value|
            ["join-#{name}-#{value}"]
          end

          define_method :build_hydra_where_options do |name, value|
            ["where-#{name}-#{value}"]
          end

          define_method :build_where do |param|
            param
          end
        end
      end
    end

    describe 'first param is Hash' do
      let(:params) { {title: 1} }

      describe 'hash has not hydra attribute' do
        it 'should call rails native "where" method' do
          klass.where(params).where_values.join.should == %q(opts: {:title=>1} - rest: [])
        end
      end

      describe 'hash has hydra attribute' do
        let(:params) { {title: 1, code: 2, name: 3} }

        it 'should call both native and overwritten "where" method' do
          condition  = %q(opts: {:title=>1} - rest: [])
          condition += ' join-code-2 where-code-2 '
          condition += %q(opts: {:name=>3} - rest: [])

          klass.where(params).where_values.join(' ').should == condition
        end
      end
    end

    describe 'first param is not Hash' do
      let(:params) { 'name = 1' }

      it 'should call rails native "where" method' do
        klass.where(params).where_values.join.should == %q(opts: "name = 1" - rest: [])
      end
    end
  end

  describe '#build_hydra_joins_values' do
    def build_connection
      klass = Class.new do
        define_method :quote_column_name do |column|
          column.to_s
        end

        define_method :quote_table_name do |table|
          table.to_s
        end

        define_method :quote do |value|
          %Q("#{value.to_s}")
        end
      end
      klass.new
    end

    def build_class(connection)
      Class.new do
        define_singleton_method :connection do
          connection
        end

        define_singleton_method :quoted_table_name do
          'hydra_string_attributes'
        end

        define_singleton_method :quoted_primary_key do
          'id'
        end

        define_singleton_method :base_class do
          Class.new do
            define_singleton_method :name do
              'BaseClass'
            end
          end
        end
      end
    end

    let(:sub_class) { build_class(build_connection) }

    before do
      klass.define_singleton_method :hydra_ref_alias do |name, value|
        "#{name}_#{value}"
      end

      klass.define_singleton_method :hydra_ref_table do |name|
        "table_#{name}"
      end

      sub = sub_class
      klass.define_singleton_method :klass do
        sub
      end
    end

    describe 'method is called in the first' do
      describe 'value is nil' do
        let(:value) { nil }
        let(:sql)   { 'LEFT JOIN table_name AS name_ ON hydra_string_attributes.id = name_.entity_id AND name_.entity_type = "BaseClass" AND name_.name = "name"' }

        it 'should return array with one SQL query element' do
          klass.send(:build_hydra_joins_values, :name, value).should == [sql]
        end
      end

      describe 'value is not nil' do
        let(:value) { 'value' }
        let(:sql)   { 'INNER JOIN table_name AS name_value ON hydra_string_attributes.id = name_value.entity_id AND name_value.entity_type = "BaseClass" AND name_value.name = "name"' }

        it 'should return array with one SQL query element' do
          klass.send(:build_hydra_joins_values, :name, value).should == [sql]
        end
      end
    end

    describe 'method is called in the first' do
      before { klass.send(:build_hydra_joins_values, :name, :value) }

      it 'should return empty array' do
        klass.send(:build_hydra_joins_values, :name, :value).should be_empty
      end
    end
  end

  describe '#build_hydra_where_options' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    it 'should create where options with table namespace' do
      klass.send(:build_hydra_where_options, :code, 'abc').should == {hydra_string_attributes_inner_code: { value: 'abc' }}
    end
  end

  describe '#hydra_ref_class' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    it 'should return class by attribute name' do
      klass.send(:hydra_ref_class, :code).should == HydraAttribute::StringAttribute
    end
  end

  describe '#hydra_ref_table' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    it 'should return table name' do
      klass.send(:hydra_ref_table, :code).should == 'hydra_string_attributes'
    end
  end

  describe '#hydra_ref_alias' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    describe 'value is nil' do
      let(:value) { nil }

      it 'should return generated alias name' do
        klass.send(:hydra_ref_alias, :code, value).should == 'hydra_string_attributes_left_code'
      end
    end

    describe 'value is not nil' do
      let(:value) { '' }

      it 'should return generated alias name' do
        klass.send(:hydra_ref_alias, :code, value).should == 'hydra_string_attributes_inner_code'
      end
    end
  end

  describe '#hydra_join_type' do
    describe 'value is nil' do
      let(:value) { nil }

      it 'should return "LEFT"' do
        klass.send(:hydra_join_type, value).should == 'LEFT'
      end
    end

    describe 'value is not nil' do
      let(:value) { '' }

      it 'should return "INNER"' do
        klass.send(:hydra_join_type, value).should == 'INNER'
      end
    end
  end

  describe '#hydra_hash_with_associations' do
    let(:values) do
      HydraAttribute::SUPPORT_TYPES.map do |type|
        {association: HydraAttribute.config.association(type), records: []}
      end
    end

    it 'should return prepared hash with association and empty records by types' do
      hydra_hash = klass.send(:hydra_hash_with_associations)
      hydra_hash.keys.should   =~ HydraAttribute::SUPPORT_TYPES
      hydra_hash.values.should =~ values
    end
  end

  describe '#group_hydra_records_by_type' do
    def build_record(type, loaded = false)
      klass = Class.new do
        @hydra_attributes = [type]
      end

      klass.define_singleton_method :hydra_attribute_types do
        @hydra_attributes
      end

      klass.send :define_method, :association do |_|
        Class.new do
          define_singleton_method :loaded? do
            loaded
          end
        end
      end

      klass.new
    end

    let(:simple_record)       { Class.new.new                }
    let(:hydra_string_record) { build_record(:string, false) }
    let(:hydra_text_record)   { build_record(:text, false)   }
    let(:hydra_float_record)  { build_record(:float, true)   }

    it 'should group records by hydra type' do
      group_records = klass.send(:group_hydra_records_by_type, [simple_record, hydra_string_record, hydra_text_record, hydra_float_record])
      group_records.each do |key, value|
        case key
        when :string then value[:records].should == [hydra_string_record]
        when :text   then value[:records].should == [hydra_text_record]
        else value[:records].should be_empty
        end
      end
    end
  end
end