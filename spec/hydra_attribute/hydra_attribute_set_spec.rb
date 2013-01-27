require 'spec_helper'

describe HydraAttribute::HydraAttributeSet do
  describe 'validations' do
    it 'should require hydra_set_id' do
      hydra_attribute_set = HydraAttribute::HydraAttributeSet.new
      hydra_attribute_set.valid?
      hydra_attribute_set.errors.should include(:hydra_set_id)

      hydra_attribute_set.hydra_set_id = 1
      hydra_attribute_set.valid?
      hydra_attribute_set.errors.should_not include(:hydra_set_id)
    end

    it 'should require hydra_attribute_id' do
      hydra_attribute_set = HydraAttribute::HydraAttributeSet.new
      hydra_attribute_set.valid?
      hydra_attribute_set.errors.should include(:hydra_attribute_id)

      hydra_attribute_set.hydra_attribute_id = 1
      hydra_attribute_set.valid?
      hydra_attribute_set.errors.should_not include(:hydra_attribute_id)
    end

    it 'should have unique hydra_set_id with hydra_attribute_id' do
      HydraAttribute::HydraAttributeSet.create(hydra_set_id: 1, hydra_attribute_id: 2).should be_persisted
      HydraAttribute::HydraAttributeSet.create(hydra_set_id: 1, hydra_attribute_id: 2).should_not be_persisted
    end
  end
end