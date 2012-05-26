require 'spec_helper'

describe HydraAttribute do
  describe '.config' do
    it 'should return and instance of HydraAttribute::Configuration' do
      HydraAttribute.config.should be_a_kind_of(HydraAttribute::Configuration)
    end

    it 'should cache config object' do
      HydraAttribute.config.should be_equal(HydraAttribute.config)
    end
  end

  describe '.setup' do
    it 'should allow to change default configuration' do
      HydraAttribute.setup { |config| config.table_prefix = 'custom_table_prefix' }
      HydraAttribute.config.table_prefix.should == 'custom_table_prefix'
    end
  end
end