require 'spec_helper'

describe HydraAttribute::IdentityMap do
  it 'acts like Hash' do
    HydraAttribute::IdentityMap.should < Hash
  end

  describe '#cache' do
    it 'should store value into cache' do
      identity_map = HydraAttribute::IdentityMap.new
      identity_map.cache(:abc, 1).should be(1)
      identity_map[:abc].should be(1)
    end

    it 'should return value from cache if it exists' do
      identity_map = HydraAttribute::IdentityMap.new
      identity_map[:abc] = 1

      identity_map.cache(:abc, 2).should be(1)
      identity_map[:abc].should be(1)
    end

    it 'should accept block for storing value into cache' do
      identity_map = HydraAttribute::IdentityMap.new

      value = identity_map.cache(:abc) { 3 }
      value.should be(3)
      identity_map[:abc].should be(3)
    end

    it 'should return value from cache if it exists and block is passed' do
      identity_map = HydraAttribute::IdentityMap.new
      identity_map[:abc] = 1

      value = identity_map.cache(:abc) { 3 }
      value.should be(1)
      identity_map[:abc].should be(1)
    end

    its 'block should have higher priority then value' do
      identity_map = HydraAttribute::IdentityMap.new
      value = identity_map.cache(:abc, 1) { 2 }
      value.should be(2)
      identity_map[:abc].should be(2)
    end
  end
end