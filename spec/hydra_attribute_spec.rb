require 'spec_helper'

describe HydraAttribute do
  around { HydraAttribute.instance_variable_set(:@config, nil) }

  describe '.config' do
    before { HydraAttribute::Config.should_receive(:new).twice }

    it 'should return cached config instance' do
      2.times { HydraAttribute.config }
    end
  end

  describe '.setup' do
    it 'should allow to change default configuration' do
      HydraAttribute.setup { |config| config.table_prefix = 'custom_table_prefix' }
      HydraAttribute.config.table_prefix.should == 'custom_table_prefix'
    end
  end
end