require 'spec_helper'

describe HydraAttribute::Model::IdentityMap do
  before do
    Object.const_set(:ExampleClass, Class.new)
    ExampleClass.send(:include, HydraAttribute::Model::IdentityMap)
  end

  after do
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

  describe '.nested_cache_keys' do
    it 'should generate nested identity map storage' do
      ExampleClass.nested_cache_keys(:one, :two)

      ExampleClass.one_identity_map.should be_a_kind_of(HydraAttribute::IdentityMap)
      ExampleClass.two_identity_map.should be_a_kind_of(HydraAttribute::IdentityMap)
    end

    it 'should generate different identity map storage' do
      ExampleClass.nested_cache_keys(:one, :two)

      im1 = ExampleClass.one_identity_map
      im2 = ExampleClass.two_identity_map

      im1.should_not be(im2)
    end

    it 'should store generated identity map storage into existed identity map for class' do
      ExampleClass.nested_cache_keys(:one, :two)

      im1 = ExampleClass.one_identity_map
      im2 = ExampleClass.two_identity_map

      ExampleClass.identity_map[:one].should be(im1)
      ExampleClass.identity_map[:two].should be(im2)
    end

    it 'should generate proxy cache method for identity map' do
      ExampleClass.nested_cache_keys(:one, :two)

      ExampleClass.one_cache(:a, 1)
      ExampleClass.two_cache(:a, 2)
      ExampleClass.one_cache(:b) { 3 }
      ExampleClass.two_cache(:b) { 4 }

      ExampleClass.one_identity_map[:a].should be(1)
      ExampleClass.two_identity_map[:a].should be(2)
      ExampleClass.one_identity_map[:b].should be(3)
      ExampleClass.two_identity_map[:b].should be(4)
    end
  end
end