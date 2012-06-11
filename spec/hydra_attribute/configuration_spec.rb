require 'spec_helper'

describe HydraAttribute::Configuration do
  let(:config) { HydraAttribute::Configuration.new }

  describe '#table_name' do
    describe 'with table prefix' do
      before { config.table_prefix = 'table_' }

      it 'should return table name' do
        config.table_name(:string).should == :table_string_attributes
      end
    end

    describe 'without table prefix' do
      before { config.table_prefix = '' }

      it 'should return table name' do
        config.table_name(:string).should == :string_attributes
      end
    end
  end

  describe '#association' do
    describe 'with association prefix' do
      before { config.association_prefix = 'assoc_' }

      it 'should return association name' do
        config.association(:string).should == :assoc_string_attributes
      end
    end

    describe 'without association prefix' do
      before { config.association_prefix = '' }

      it 'should return association name' do
        config.association(:string).should == :string_attributes
      end
    end
  end

  describe '#associated_model_name' do
    describe 'use module wrapper' do
      before { config.use_module_for_associated_models = true }

      it 'should return associated model name' do
        config.associated_model_name(:string).should == 'HydraAttribute::StringAttribute'
      end
    end

    describe 'don not use module wrapper' do
      before { config.use_module_for_associated_models = false }

      it 'should return associated model name' do
        config.associated_model_name(:string).should == 'StringAttribute'
      end
    end
  end

  describe '#associated_const_name' do
    it 'should return constant name for new model' do
      config.associated_const_name(:string).should == :StringAttribute
    end
  end
end