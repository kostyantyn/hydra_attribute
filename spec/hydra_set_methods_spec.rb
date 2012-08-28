require 'spec_helper'

describe HydraAttribute::HydraSetMethods do
  describe '.hydra_sets' do
    it 'should return blank array if there are not any hydra sets for entity' do
      Product.hydra_sets.should be_blank
    end

    it 'should return all hydra sets for entity' do
      default = Product.hydra_sets.create!(name: 'Default')
      general = Product.hydra_sets.create!(name: 'General')

      Product.should have(2).hydra_sets
      Product.hydra_sets.first.should == default
      Product.hydra_sets.last.should  == general
    end

    it 'should cache result' do
      HydraAttribute::HydraSet.should_receive(:where).once.and_return([])

      2.times { Product.hydra_sets }
    end

    it 'should reset method cache after creating hydra set' do
      Product.hydra_sets # cache
      default = Product.hydra_sets.create!(name: 'Default')

      Product.hydra_sets.should == [default]
    end

    it 'should reset method cache after updating hydra set' do
      Product.hydra_sets.create!(name: 'Default')
      Product.hydra_sets # cache

      Product.hydra_sets.first.update_attributes(name: 'General')
      Product.hydra_sets.first.name.should == 'General'
    end

    it 'should reset method cache after destroying hydra set' do
      default = Product.hydra_sets.create!(name: 'Default')
      general = Product.hydra_sets.create!(name: 'General')
      default.destroy

      Product.should have(1).hydra_sets
      Product.hydra_sets.should == [general]
    end
  end

  describe '.hydra_set' do
    it 'should return hydra set by id' do
      default = Product.hydra_sets.create(name: 'Default')
      general = Product.hydra_sets.create(name: 'General')

      Product.hydra_set(default.id).should == default
      Product.hydra_set(general.id).should == general
    end

    it 'should return hydra set by name' do
      default = Product.hydra_sets.create(name: 'Default')
      general = Product.hydra_sets.create(name: 'General')

      Product.hydra_set(default.name).should == default
      Product.hydra_set(general.name).should == general
    end

    it 'should cache result' do
      Product.hydra_sets.create(name: 'Default')
      Product.hydra_sets.create(name: 'General')

      hydra_sets = Product.hydra_sets
      Product.should_receive(:hydra_sets).once.and_return(hydra_sets)

      2.times { Product.hydra_set('General') }
    end

    it 'should cache nil result' do
      Product.should_receive(:hydra_sets).once.and_return([])

      2.times { Product.hydra_set('Default') }
    end

    it 'should reset method cache after creating hydra set' do
      Product.hydra_set('Default') # cache
      default = Product.hydra_sets.create!(name: 'Default')

      Product.hydra_set('Default').should == default
    end

    it 'should reset method cache after updating hydra set' do
      default = Product.hydra_sets.create!(name: 'Default')
      Product.hydra_set('Default').update_attributes(name: 'General')

      Product.hydra_set('Default').should be_nil
      Product.hydra_set('General').should == default
    end

    it 'should reset method cache after destroying hydra set' do
      Product.hydra_sets.create!(name: 'Default')
      Product.hydra_sets.create!(name: 'General')
      Product.hydra_set('Default').destroy

      Product.hydra_set('Default').should be_nil
      Product.hydra_set('General').should_not be_nil
    end
  end

  describe '.hydra_set_ids' do
    it 'should return all hydra set ids' do
      default = Product.hydra_sets.create(name: 'Default')
      general = Product.hydra_sets.create(name: 'General')

      Product.hydra_set_ids.should == [default.id, general.id]
    end

    it 'should cache result' do
      default = Product.hydra_sets.create(name: 'Default')
      general = Product.hydra_sets.create(name: 'General')

      Product.should_receive(:hydra_sets).once.and_return([default, general])
      2.times { Product.hydra_set_ids.should == [default.id, general.id] }
    end

    it 'should reset method cache after creating hydra set' do
      Product.hydra_set_ids # cache
      default = Product.hydra_sets.create!(name: 'Default')

      Product.hydra_set_ids.should == [default.id]
    end

    it 'should reset method cache after updating hydra set' do
      Product.hydra_set_ids # cache
      default = Product.hydra_sets.create!(name: 'Default')
      default.update_attributes(name: 'General')

      Product.should_receive(:hydra_sets).once.and_return([default])
      2.times { Product.hydra_set_ids.should == [default.id] }
    end

    it 'should reset method cache after destroying hydra set' do
      default = Product.hydra_sets.create!(name: 'Default')
      general = Product.hydra_sets.create!(name: 'General')
      default.destroy

      Product.should have(1).hydra_set_ids
      Product.hydra_set_ids.should == [general.id]
    end
  end

  describe '.hydra_set_names' do
    it 'should return all hydra set names' do
      default = Product.hydra_sets.create(name: 'Default')
      general = Product.hydra_sets.create(name: 'General')

      Product.hydra_set_names.should == [default.name, general.name]
    end

    it 'should cache result' do
      default = Product.hydra_sets.create(name: 'Default')
      general = Product.hydra_sets.create(name: 'General')

      Product.should_receive(:hydra_sets).once.and_return([default, general])
      2.times { Product.hydra_set_names.should == [default.name, general.name] }
    end

    it 'should reset method cache after creating hydra set' do
      Product.hydra_set_names # cache
      default = Product.hydra_sets.create!(name: 'Default')

      Product.hydra_set_names.should == [default.name]
    end

    it 'should reset method cache after updating hydra set' do
      Product.hydra_set_names # cache
      default = Product.hydra_sets.create!(name: 'Default')
      default.update_attributes(name: 'General')

      Product.should_receive(:hydra_sets).once.and_return([default])
      2.times { Product.hydra_set_names.should == [default.name] }
    end

    it 'should reset method cache after destroying hydra set' do
      default = Product.hydra_sets.create!(name: 'Default')
      general = Product.hydra_sets.create!(name: 'General')
      default.destroy

      Product.should have(1).hydra_set_names
      Product.hydra_set_names.should == [general.name]
    end
  end

  describe '.clear_hydra_set_cache!' do
    it 'should reset cache' do
      Product.should_receive(:unmemoized_hydra_sets).twice.and_return([])
      Product.should_receive(:unmemoized_hydra_set).twice
      Product.should_receive(:unmemoized_hydra_set_ids).twice
      Product.should_receive(:unmemoized_hydra_set_names).twice

      block = proc do
        Product.hydra_sets
        Product.hydra_set('Default')
        Product.hydra_set_ids
        Product.hydra_set_names
      end

      2.times(&block)
      Product.clear_hydra_set_cache!
      2.times(&block)
    end
  end
end