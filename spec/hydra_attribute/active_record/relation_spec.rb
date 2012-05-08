require 'spec_helper'

describe HydraAttribute::ActiveRecord::Relation do
  def record_class(loaded_associations = false)
    Class.new do
      define_singleton_method :base_class do
        @base_class ||= Class.new do
          define_singleton_method :hydra_attribute_types do
            [:string]
          end
        end
      end

      define_singleton_method :reflect_on_association do |_|
        true
      end

      @hydra_attributes = {string: [:code]}
      define_singleton_method :hydra_attribute_types do
        [:string]
      end

      define_singleton_method :hydra_attribute_names do
        [:code]
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

  describe '#build_hydra_joins_values' do
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
      klass.build_hydra_where_options(:code, 'abc').should == {hydra_string_attributes_inner_code: { value: 'abc' }}
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
      klass.hydra_ref_class(:code).should == HydraAttribute::StringAttribute
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
      klass.hydra_ref_table(:code).should == 'hydra_string_attributes'
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
        klass.hydra_ref_alias(:code, value).should == 'hydra_string_attributes_left_code'
      end
    end

    describe 'value is not nil' do
      let(:value) { '' }

      it 'should return generated alias name' do
        klass.hydra_ref_alias(:code, value).should == 'hydra_string_attributes_inner_code'
      end
    end
  end

  describe '#hydra_join_type' do
    describe 'value is nil' do
      let(:value) { nil }

      it 'should return "LEFT"' do
        klass.hydra_join_type(value).should == 'LEFT'
      end
    end

    describe 'value is not nil' do
      let(:value) { '' }

      it 'should return "INNER"' do
        klass.hydra_join_type(value).should == 'INNER'
      end
    end
  end
end