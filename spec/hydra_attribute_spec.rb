require 'spec_helper'

describe HydraAttribute do
  describe '#identity_map' do
    it 'should return IdentityMap object' do
      HydraAttribute.identity_map.should be_a_kind_of(HydraAttribute::IdentityMap)
    end

    it 'should cache identity map object' do
      im1 = HydraAttribute.identity_map
      im2 = HydraAttribute.identity_map
      im1.should be(im2)
    end

    it 'should store identity map into current thread' do
      im = HydraAttribute.identity_map
      Thread.current[:hydra_attribute].should be(im)
    end
  end

  describe '#cache' do
    it 'should proxy method to identity map' do
      HydraAttribute.cache(:a, 1)
      HydraAttribute.identity_map.cache(:a, 2).should be(1)

      HydraAttribute.cache(:b) { 1 }
      HydraAttribute.identity_map.cache(:b) { 2 }.should be(1)
    end
  end
end