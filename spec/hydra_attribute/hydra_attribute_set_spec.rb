require 'spec_helper'

describe HydraAttribute::HydraAttributeSet do
  describe '.hydra_attribute_sets_by_hydra_set_id' do
    it 'should return all models with the following hydra_set_id' do
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(1, 1)')
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(2, 1)')
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(2, 2)')

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1)
      hydra_attribute_sets.should have(2).records
      hydra_attribute_sets[0].hydra_attribute_id.should be(1)
      hydra_attribute_sets[1].hydra_attribute_id.should be(2)
    end

    it 'should return blank array if there are not any models with the following hydra_set_id' do
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1).should be_blank
    end

    it 'should cache result into the nested hydra_set cache' do
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(1, 1)')
      HydraAttribute::HydraAttributeSet.hydra_set_identity_map[1].should be_nil

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1)
      hydra_attribute_sets.should have(1).item
      HydraAttribute::HydraAttributeSet.hydra_set_identity_map[1].should == hydra_attribute_sets
    end

    it 'should accept string as well' do
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(2, 1)')
      HydraAttribute::HydraAttributeSet.hydra_set_identity_map[1].should be_nil

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id('1')
      hydra_attribute_sets.should have(1).item
      HydraAttribute::HydraAttributeSet.hydra_set_identity_map[1].should == hydra_attribute_sets
    end
  end

  describe '.hydra_attribute_sets_by_hydra_attribute_id' do
    it 'should return all models with the following hydra_attribute_id' do
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(1, 1)')
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(2, 1)')
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(2, 2)')

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(2)
      hydra_attribute_sets.should have(2).records
      hydra_attribute_sets[0].hydra_set_id.should be(1)
      hydra_attribute_sets[1].hydra_set_id.should be(2)
    end

    it 'should return blank array if there are not any models with the following hydra_attribute_id' do
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(1).should be_blank
    end

    it 'should cache result into the nested hydra_attribute cache' do
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(1, 1)')
      HydraAttribute::HydraAttributeSet.hydra_attribute_identity_map[1].should be_nil

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(1)
      hydra_attribute_sets.should have(1).item
      HydraAttribute::HydraAttributeSet.hydra_attribute_identity_map[1].should == hydra_attribute_sets
    end

    it 'should accept string as well' do
      ::ActiveRecord::Base.connection.insert('INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(1, 2)')
      HydraAttribute::HydraAttributeSet.hydra_attribute_identity_map[1].should be_nil

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id('1')
      hydra_attribute_sets.should have(1).item
      HydraAttribute::HydraAttributeSet.hydra_attribute_identity_map[1].should == hydra_attribute_sets
    end
  end

  describe '#create' do
    it 'should store created record into hydra_set cache if it exists' do
      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1)
      hydra_attribute_sets.should be_blank

      hydra_attribute_set = HydraAttribute::HydraAttributeSet.new(hydra_attribute_id: 2, hydra_set_id: 1)
      hydra_attribute_set.save

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_set_identity_map[1]
      hydra_attribute_sets.should have(1).item
      hydra_attribute_sets.should include(hydra_attribute_set)
    end

    it 'should not store created record into hydra_set cache if it does not exist yet' do
      hydra_attribute_set = HydraAttribute::HydraAttributeSet.new(hydra_attribute_id: 2, hydra_set_id: 1)
      hydra_attribute_set.save

      HydraAttribute::HydraAttributeSet.hydra_set_cache(1).should be_blank
    end

    it 'should store created record into hydra_attribute cache if it exists' do
      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(1)
      hydra_attribute_sets.should be_blank

      hydra_attribute_set = HydraAttribute::HydraAttributeSet.new(hydra_attribute_id: 1, hydra_set_id: 2)
      hydra_attribute_set.save

      hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_identity_map[1]
      hydra_attribute_sets.should have(1).item
      hydra_attribute_sets.should include(hydra_attribute_set)
    end

    it 'should not store created record into hydra_attribute cache if it does not exist yet' do
      hydra_attribute_set = HydraAttribute::HydraAttributeSet.new(hydra_attribute_id: 1, hydra_set_id: 2)
      hydra_attribute_set.save

      HydraAttribute::HydraAttributeSet.hydra_set_cache(1).should be_blank
    end
  end

  describe '#delete' do
    it 'should remove model from hydra_set cache if it exists' do
      hydra_attribute_set1 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 1, hydra_attribute_id: 1)
      hydra_attribute_set2 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 1, hydra_attribute_id: 2)
      hydra_attribute_set3 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 2, hydra_attribute_id: 3)

      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1).should have(2).model
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(2).should have(1).model

      hydra_attribute_set2.destroy

      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1).should have(1).model
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(2).should have(1).model

      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1).should include(hydra_attribute_set1)
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(2).should include(hydra_attribute_set3)
    end

    it 'should not touch hydra_set cache if it is nil' do
      HydraAttribute::HydraAttributeSet.hydra_set_identity_map[1].should be_nil

      hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 1, hydra_attribute_id: 1)
      hydra_attribute_set.destroy

      HydraAttribute::HydraAttributeSet.hydra_set_identity_map[1].should be_nil
    end

    it 'should remove model from hydra_attribute cache if it exists' do
      hydra_attribute_set1 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 1, hydra_attribute_id: 1)
      hydra_attribute_set2 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 2, hydra_attribute_id: 1)
      hydra_attribute_set3 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 3, hydra_attribute_id: 2)

      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(1).should have(2).model
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(2).should have(1).model

      hydra_attribute_set2.destroy

      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(1).should have(1).model
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(2).should have(1).model

      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(1).should include(hydra_attribute_set1)
      HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(2).should include(hydra_attribute_set3)
    end

    it 'should not touch hydra_attribute cache if it is nil' do
      HydraAttribute::HydraAttributeSet.hydra_attribute_identity_map[1].should be_nil

      hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_set_id: 1, hydra_attribute_id: 1)
      hydra_attribute_set.destroy

      HydraAttribute::HydraAttributeSet.hydra_attribute_identity_map[1].should be_nil
    end
  end

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