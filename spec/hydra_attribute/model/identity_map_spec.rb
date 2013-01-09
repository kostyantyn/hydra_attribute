require 'spec_helper'

describe HydraAttribute::Model::IdentityMap do
  before(:all) do
    Object.const_set(:ExampleClass, Class.new)
    ExampleClass.send(:include, HydraAttribute::Model::IdentityMap)
  end

  after(:all) do
    Object.send(:remove_const, :ExampleClass)
  end

  describe '.identity_map_cache_key' do
    it 'should create cache key based on class name' do
      ExampleClass.identity_map_cache_key.should be(:example_class)
    end
  end

  describe '.identity_map' do
    it 'should return identity map object' do
      ExampleClass.identity_map.should be_a_kind_of(HydraAttribute::IdentityMap)
    end

    it 'should store identity map in global identity map object' do
      identity_map = ExampleClass.identity_map
      HydraAttribute.identity_map[:example_class].should be(identity_map)
    end
  end

  describe '.cache' do
    it 'should proxy method to identity map object' do
      ExampleClass.cache(:a, 1)
      ExampleClass.identity_map.cache(:a, 2).should be(1)

      ExampleClass.cache(:b) { 2 }
      ExampleClass.identity_map.cache(:b) { 3 }.should be(2)
    end
  end
end