require 'spec_helper'

describe HydraAttribute::HydraMethods do
  describe '.hydra_set_attributes' do
    let!(:hydra_set)        { Product.hydra_sets.create(name: 'Default') }
    let!(:hydra_attribute1) { hydra_set.hydra_attributes.create(name: 'a', backend_type: 'string') }
    let!(:hydra_attribute2) { Product.hydra_attributes.create(name: 'b', backend_type: 'string') }

    it 'should return hydra attributes for specific hydra set' do
      Product.hydra_set_attributes(hydra_set.id).should have(1).hydra_attribute
      Product.hydra_set_attributes(hydra_set.id).first.should == hydra_attribute1
    end

    it 'should return all hydra attributes if hydra set does not exist' do
      Product.hydra_set_attributes(0).should have(2).hydra_attributes
      Product.hydra_set_attributes(0).first.should == hydra_attribute1
      Product.hydra_set_attributes(0).last.should  == hydra_attribute2
    end
  end

  describe '.hydra_set_attribute_ids' do
    describe 'create hydra attributes' do
      let!(:hydra_set)        { Product.hydra_sets.create(name: 'Default') }
      let!(:hydra_attribute1) { hydra_set.hydra_attributes.create(name: 'a', backend_type: 'string') }
      let!(:hydra_attribute2) { Product.hydra_attributes.create(name: 'b', backend_type: 'string') }

      it 'should return hydra attribute ids for specific hydra set' do
        Product.hydra_set_attribute_ids(hydra_set.id).should have(1).hydra_attribute
        Product.hydra_set_attribute_ids(hydra_set.id).first.should == hydra_attribute1.id
      end

      it 'should return all hydra attribute ids if hydra set does not exist' do
        Product.hydra_set_attribute_ids(0).should have(2).hydra_attributes
        Product.hydra_set_attribute_ids(0).first.should == hydra_attribute1.id
        Product.hydra_set_attribute_ids(0).last.should  == hydra_attribute2.id
      end
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_set_attribute_ids).once
      2.times { Product.hydra_set_attribute_ids(1) }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_set_attribute_ids).twice

      Product.hydra_set_attribute_ids(1)
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_set_attribute_ids(1)
    end

    it 'should reset method cache after updating hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_ids).twice

      Product.hydra_set_attribute_ids(1)
      one.update_attributes(name: 'two')
      Product.hydra_set_attribute_ids(1)
    end

    it 'should reset method cache after removing hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_ids).twice

      Product.hydra_set_attribute_ids(1)
      one.destroy
      Product.hydra_set_attribute_ids(1)
    end
  end

  describe '.hydra_set_attribute_names' do
    describe 'create hydra attributes' do
      let!(:hydra_set)        { Product.hydra_sets.create(name: 'Default') }
      let!(:hydra_attribute1) { hydra_set.hydra_attributes.create(name: 'a', backend_type: 'string') }
      let!(:hydra_attribute2) { Product.hydra_attributes.create(name: 'b', backend_type: 'string') }

      it 'should return hydra attribute names for specific hydra set' do
        Product.hydra_set_attribute_names(hydra_set.id).should have(1).hydra_attribute
        Product.hydra_set_attribute_names(hydra_set.id).first.should == hydra_attribute1.name
      end

      it 'should return all hydra attribute names if hydra set does not exist' do
        Product.hydra_set_attribute_names(0).should have(2).hydra_attributes
        Product.hydra_set_attribute_names(0).first.should == hydra_attribute1.name
        Product.hydra_set_attribute_names(0).last.should  == hydra_attribute2.name
      end
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_set_attribute_names).once
      2.times { Product.hydra_set_attribute_names(1) }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_set_attribute_names).twice

      Product.hydra_set_attribute_names(1)
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_set_attribute_names(1)
    end

    it 'should reset method cache after updating hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_names).twice

      Product.hydra_set_attribute_names(1)
      one.update_attributes(name: 'two')
      Product.hydra_set_attribute_names(1)
    end

    it 'should reset method cache after removing hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_names).twice

      Product.hydra_set_attribute_names(1)
      one.destroy
      Product.hydra_set_attribute_names(1)
    end
  end

  describe '.hydra_set_attribute_backend_types' do
    describe 'create hydra attributes' do
      let!(:hydra_set)        { Product.hydra_sets.create(name: 'Default') }
      let!(:hydra_attribute1) { hydra_set.hydra_attributes.create(name: 'a', backend_type: 'string') }
      let!(:hydra_attribute2) { Product.hydra_attributes.create(name: 'b', backend_type: 'integer') }

      it 'should return hydra attribute backend types for specific hydra set' do
        Product.hydra_set_attribute_backend_types(hydra_set.id).should == [hydra_attribute1.backend_type]
      end

      it 'should return all hydra attribute backend types if hydra set does not exist' do
        Product.hydra_set_attribute_backend_types(0).should =~ [hydra_attribute1.backend_type, hydra_attribute2.backend_type]
      end

      it 'should return uniq attribute backend type names' do
        hydra_set.hydra_attributes.create(name: 'c', backend_type: 'string')
        hydra_set.hydra_attributes.create(name: 'd', backend_type: 'integer')

        backend_types = Product.hydra_set_attribute_backend_types(hydra_set.id)
        backend_types.should =~ %w(string integer)
      end
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_set_attribute_backend_types).once
      2.times { Product.hydra_set_attribute_backend_types(1) }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_set_attribute_backend_types).twice

      Product.hydra_set_attribute_backend_types(1)
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_set_attribute_backend_types(1)
    end

    it 'should reset method cache after updating hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_backend_types).twice

      Product.hydra_set_attribute_backend_types(1)
      one.update_attributes(name: 'two')
      Product.hydra_set_attribute_backend_types(1)
    end

    it 'should reset method cache after removing hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_backend_types).twice

      Product.hydra_set_attribute_backend_types(1)
      one.destroy
      Product.hydra_set_attribute_backend_types(1)
    end
  end

  describe '.hydra_set_attributes_by_backend_type' do
    describe 'create attributes' do
      let!(:hydra_set)   { Product.hydra_sets.create(name: 'Default') }
      let!(:hydra_attr1) { hydra_set.hydra_attributes.create(name: 'a1', backend_type: 'string') }
      let!(:hydra_attr2) { hydra_set.hydra_attributes.create(name: 'a2', backend_type: 'string') }
      let!(:hydra_attr3) { hydra_set.hydra_attributes.create(name: 'a3', backend_type: 'integer') }
      let!(:hydra_attr4) { Product.hydra_attributes.create(name: 'a4', backend_type: 'string') }

      it 'should return hydra attributes for hydra set grouped by backend type' do
        hydra_attributes = Product.hydra_set_attributes_by_backend_type(hydra_set.id)

        hydra_attributes['string'].should  =~ [hydra_attr1, hydra_attr2]
        hydra_attributes['integer'].should == [hydra_attr3]
      end

      it 'should return all hydra attributes grouped by backend type if hydra set does not exist' do
        hydra_attributes = Product.hydra_set_attributes_by_backend_type(0)

        hydra_attributes['string'].should  =~ [hydra_attr1, hydra_attr2, hydra_attr4]
        hydra_attributes['integer'].should == [hydra_attr3]
      end
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_set_attributes_by_backend_type).once
      2.times { Product.hydra_set_attributes_by_backend_type(1) }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_set_attributes_by_backend_type).twice

      Product.hydra_set_attributes_by_backend_type(1)
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_set_attributes_by_backend_type(1)
    end

    it 'should reset method cache after updating hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attributes_by_backend_type).twice

      Product.hydra_set_attributes_by_backend_type(1)
      one.update_attributes(name: 'two')
      Product.hydra_set_attributes_by_backend_type(1)
    end

    it 'should reset method cache after removing hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attributes_by_backend_type).twice

      Product.hydra_set_attributes_by_backend_type(1)
      one.destroy
      Product.hydra_set_attributes_by_backend_type(1)
    end
  end

  describe '.hydra_set_attribute_ids_by_backend_type' do
    describe 'create attributes' do
      let!(:hydra_set)   { Product.hydra_sets.create(name: 'Default') }
      let!(:hydra_attr1) { hydra_set.hydra_attributes.create(name: 'a1', backend_type: 'string') }
      let!(:hydra_attr2) { hydra_set.hydra_attributes.create(name: 'a2', backend_type: 'string') }
      let!(:hydra_attr3) { hydra_set.hydra_attributes.create(name: 'a3', backend_type: 'integer') }
      let!(:hydra_attr4) { Product.hydra_attributes.create(name: 'a4', backend_type: 'string') }

      it 'should return hydra attribute ids for hydra set grouped by backend type' do
        hydra_attributes = Product.hydra_set_attribute_ids_by_backend_type(hydra_set.id)

        hydra_attributes['string'].should  =~ [hydra_attr1.id, hydra_attr2.id]
        hydra_attributes['integer'].should == [hydra_attr3.id]
      end

      it 'should return all hydra attribute ids grouped by backend type if hydra set does not exist' do
        hydra_attributes = Product.hydra_set_attribute_ids_by_backend_type(0)

        hydra_attributes['string'].should  =~ [hydra_attr1.id, hydra_attr2.id, hydra_attr4.id]
        hydra_attributes['integer'].should == [hydra_attr3.id]
      end
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_set_attribute_ids_by_backend_type).once
      2.times { Product.hydra_set_attribute_ids_by_backend_type(1) }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_set_attribute_ids_by_backend_type).twice

      Product.hydra_set_attribute_ids_by_backend_type(1)
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_set_attribute_ids_by_backend_type(1)
    end

    it 'should reset method cache after updating hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_ids_by_backend_type).twice

      Product.hydra_set_attribute_ids_by_backend_type(1)
      one.update_attributes(name: 'two')
      Product.hydra_set_attribute_ids_by_backend_type(1)
    end

    it 'should reset method cache after removing hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_ids_by_backend_type).twice

      Product.hydra_set_attribute_ids_by_backend_type(1)
      one.destroy
      Product.hydra_set_attribute_ids_by_backend_type(1)
    end
  end

  describe '.hydra_set_attribute_names_by_backend_type' do
    describe 'create attributes' do
      let!(:hydra_set)   { Product.hydra_sets.create(name: 'Default') }
      let!(:hydra_attr1) { hydra_set.hydra_attributes.create(name: 'a1', backend_type: 'string') }
      let!(:hydra_attr2) { hydra_set.hydra_attributes.create(name: 'a2', backend_type: 'string') }
      let!(:hydra_attr3) { hydra_set.hydra_attributes.create(name: 'a3', backend_type: 'integer') }
      let!(:hydra_attr4) { Product.hydra_attributes.create(name: 'a4', backend_type: 'string') }

      it 'should return hydra attribute names for hydra set grouped by backend type' do
        hydra_attributes = Product.hydra_set_attribute_names_by_backend_type(hydra_set.id)

        hydra_attributes['string'].should  =~ [hydra_attr1.name, hydra_attr2.name]
        hydra_attributes['integer'].should == [hydra_attr3.name]
      end

      it 'should return all hydra attribute names grouped by backend type if hydra set does not exist' do
        hydra_attributes = Product.hydra_set_attribute_names_by_backend_type(0)

        hydra_attributes['string'].should  =~ [hydra_attr1.name, hydra_attr2.name, hydra_attr4.name]
        hydra_attributes['integer'].should == [hydra_attr3.name]
      end
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_set_attribute_names_by_backend_type).once
      2.times { Product.hydra_set_attribute_names_by_backend_type(1) }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_set_attribute_names_by_backend_type).twice

      Product.hydra_set_attribute_names_by_backend_type(1)
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_set_attribute_names_by_backend_type(1)
    end

    it 'should reset method cache after updating hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_names_by_backend_type).twice

      Product.hydra_set_attribute_names_by_backend_type(1)
      one.update_attributes(name: 'two')
      Product.hydra_set_attribute_names_by_backend_type(1)
    end

    it 'should reset method cache after removing hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_set_attribute_names_by_backend_type).twice

      Product.hydra_set_attribute_names_by_backend_type(1)
      one.destroy
      Product.hydra_set_attribute_names_by_backend_type(1)
    end
  end

  describe '.hydra_set_attributes_for_backend_type' do
    let!(:hydra_set)   { Product.hydra_sets.create(name: 'Default') }
    let!(:hydra_attr1) { hydra_set.hydra_attributes.create(name: 'a1', backend_type: 'string') }
    let!(:hydra_attr2) { hydra_set.hydra_attributes.create(name: 'a2', backend_type: 'string') }
    let!(:hydra_attr3) { hydra_set.hydra_attributes.create(name: 'a3', backend_type: 'integer') }
    let!(:hydra_attr4) { Product.hydra_attributes.create(name: 'a4', backend_type: 'integer') }

    describe 'hydra set exists' do
      it 'should return hydra attributes for specific hydra set and backend type' do
        Product.hydra_set_attributes_for_backend_type(hydra_set.id, 'string').should  =~ [hydra_attr1, hydra_attr2]
        Product.hydra_set_attributes_for_backend_type(hydra_set.id, 'integer').should == [hydra_attr3]
      end

      it 'should return blank array if there are not any hydra attributes' do
        Product.hydra_set_attributes_for_backend_type(hydra_set.id, 'text').should == []
      end
    end

    describe 'hydra set does not exist' do
      it 'should return all hydra attributes for specific backend type' do
        Product.hydra_set_attributes_for_backend_type(0, 'string').should   =~ [hydra_attr1, hydra_attr2]
        Product.hydra_set_attributes_for_backend_type(0, 'integer').should  =~ [hydra_attr3, hydra_attr4]
      end

      it 'should return blank array if there are not any hydra attributes' do
        Product.hydra_set_attributes_for_backend_type(0, 'text').should == []
      end
    end
  end

  describe '.hydra_set_attribute_ids_for_backend_type' do
    let!(:hydra_set)   { Product.hydra_sets.create(name: 'Default') }
    let!(:hydra_attr1) { hydra_set.hydra_attributes.create(name: 'a1', backend_type: 'string') }
    let!(:hydra_attr2) { hydra_set.hydra_attributes.create(name: 'a2', backend_type: 'string') }
    let!(:hydra_attr3) { hydra_set.hydra_attributes.create(name: 'a3', backend_type: 'integer') }
    let!(:hydra_attr4) { Product.hydra_attributes.create(name: 'a4', backend_type: 'integer') }

    describe 'hydra set exists' do
      it 'should return hydra attribute ids for specific hydra set and backend type' do
        Product.hydra_set_attribute_ids_for_backend_type(hydra_set.id, 'string').should  =~ [hydra_attr1.id, hydra_attr2.id]
        Product.hydra_set_attribute_ids_for_backend_type(hydra_set.id, 'integer').should == [hydra_attr3.id]
      end

      it 'should return blank array if there are not any hydra attributes' do
        Product.hydra_set_attribute_ids_for_backend_type(hydra_set.id, 'text').should == []
      end
    end

    describe 'hydra set does not exist' do
      it 'should return all hydra attribute ids for specific backend type' do
        Product.hydra_set_attribute_ids_for_backend_type(0, 'string').should   =~ [hydra_attr1.id, hydra_attr2.id]
        Product.hydra_set_attribute_ids_for_backend_type(0, 'integer').should  =~ [hydra_attr3.id, hydra_attr4.id]
      end

      it 'should return blank array if there are not any hydra attributes' do
        Product.hydra_set_attributes_for_backend_type(0, 'text').should == []
      end
    end
  end

  describe '.hydra_set_attribute_names_for_backend_type' do
    let!(:hydra_set)   { Product.hydra_sets.create(name: 'Default') }
    let!(:hydra_attr1) { hydra_set.hydra_attributes.create(name: 'a1', backend_type: 'string') }
    let!(:hydra_attr2) { hydra_set.hydra_attributes.create(name: 'a2', backend_type: 'string') }
    let!(:hydra_attr3) { hydra_set.hydra_attributes.create(name: 'a3', backend_type: 'integer') }
    let!(:hydra_attr4) { Product.hydra_attributes.create(name: 'a4', backend_type: 'integer') }

    describe 'hydra set exists' do
      it 'should return hydra attribute names for specific hydra set and backend type' do
        Product.hydra_set_attribute_names_for_backend_type(hydra_set.id, 'string').should  =~ [hydra_attr1.name, hydra_attr2.name]
        Product.hydra_set_attribute_names_for_backend_type(hydra_set.id, 'integer').should == [hydra_attr3.name]
      end

      it 'should return blank array if there are not any hydra attributes' do
        Product.hydra_set_attribute_names_for_backend_type(hydra_set.id, 'text').should == []
      end
    end

    describe 'hydra set does not exist' do
      it 'should return all hydra attribute names for specific backend type' do
        Product.hydra_set_attribute_names_for_backend_type(0, 'string').should   =~ [hydra_attr1.name, hydra_attr2.name]
        Product.hydra_set_attribute_names_for_backend_type(0, 'integer').should  =~ [hydra_attr3.name, hydra_attr4.name]
      end

      it 'should return blank array if there are not any hydra attributes' do
        Product.hydra_set_attribute_names_for_backend_type(0, 'text').should == []
      end
    end
  end

  describe '.clear_hydra_methods!' do
    it 'should reset cache for all methods' do
      Product.should_receive(:clear_hydra_attribute_cache!)
      Product.should_receive(:clear_hydra_set_cache!)
      Product.should_receive(:clear_hydra_value_cache!)

      [
        :unmemoized_hydra_set_attribute_ids,
        :unmemoized_hydra_set_attribute_names,
        :unmemoized_hydra_set_attribute_backend_types,
        :unmemoized_hydra_set_attributes_by_backend_type,
        :unmemoized_hydra_set_attribute_ids_by_backend_type,
        :unmemoized_hydra_set_attribute_names_by_backend_type
      ].each do |symbol|
        Product.should_receive(symbol).twice.and_return([])
      end

      block = lambda do
        Product.hydra_set_attribute_ids(1)
        Product.hydra_set_attribute_names(1)
        Product.hydra_set_attribute_backend_types(1)
        Product.hydra_set_attributes_by_backend_type(1)
        Product.hydra_set_attribute_ids_by_backend_type(1)
        Product.hydra_set_attribute_names_by_backend_type(1)
      end

      block.call
      Product.clear_hydra_method_cache!
      block.call
    end
  end
end