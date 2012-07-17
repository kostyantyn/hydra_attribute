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
end