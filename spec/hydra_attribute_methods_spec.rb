require 'spec_helper'

describe HydraAttribute::HydraAttributeMethods do
  describe '.hydra_attributes' do
    it 'should return blank array if there are not any hydra attributes for entity' do
      Product.hydra_attributes.should be_blank
    end

    it 'should return all hydra attributes for entity' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      two = Product.hydra_attributes.create(name: 'two', backend_type: 'string')

      Product.should have(2).hydra_attributes
      Product.hydra_attributes.first.should == one
      Product.hydra_attributes.last.should  == two
    end

    it 'should cache result' do
      # hydra_attributes method is called for generation hydra methods
      # so this method is already cached and this cache should be removed manually
      Product.send(:remove_instance_variable, :@hydra_attributes) if Product.instance_variable_defined?(:@hydra_attributes)

      Product.should_receive(:unmemoized_hydra_attributes).once
      2.times { Product.hydra_attributes }
    end

    it 'should reset method cache after creating hydra attribute' do
      hydra_attributes = Product.hydra_attributes
      Product.should_receive(:unmemoized_hydra_attributes).once

      hydra_attributes.create(name: 'one', backend_type: 'string')
      2.times { Product.hydra_attributes }
    end

    it 'should reset method cache after updating hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attributes).once

      hydra_attribute.update_attributes(name: 'two')
      2.times { Product.hydra_attributes }
    end

    it 'should reset method cache after removing hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'once', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attributes).once

      hydra_attribute.destroy
      2.times { Product.hydra_attributes }
    end
  end

  describe '.hydra_attribute' do
    it 'should return hydra attribute by id' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      two = Product.hydra_attributes.create(name: 'two', backend_type: 'string')

      Product.hydra_attribute(one.id).should == one
      Product.hydra_attribute(two.id).should == two
    end

    it 'should return hydra attribute by name' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      two = Product.hydra_attributes.create(name: 'two', backend_type: 'string')

      Product.hydra_attribute(one.name).should == one
      Product.hydra_attribute(two.name).should == two
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_attribute).once
      2.times { Product.hydra_attribute('name') }
    end

    it 'should reset method cache after creating hydra attribute' do
      hydra_attributes = Product.hydra_attributes
      Product.should_receive(:unmemoized_hydra_attribute).twice

      Product.hydra_attribute('one')
      hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attribute('one')
    end

    it 'should reset method cache after updating hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute).twice

      Product.hydra_attribute('one')
      hydra_attribute.update_attributes(name: 'two')
      Product.hydra_attribute('one')
    end

    it 'should reset method cache after removing hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'once', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute).twice

      Product.hydra_attribute('one')
      hydra_attribute.destroy
      Product.hydra_attribute('one')
    end
  end

  describe '.hydra_attribute_backend_types' do
    it 'should return all backend types' do
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      Product.hydra_attributes.create(name: 'three', backend_type: 'integer')

      Product.hydra_attribute_backend_types.should =~ %w(string integer)
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_attribute_backend_types).once
      2.times { Product.hydra_attribute_backend_types }
    end

    it 'should reset method cache after creating hydra attribute' do
      hydra_attributes = Product.hydra_attributes
      Product.should_receive(:unmemoized_hydra_attribute_backend_types).twice

      Product.hydra_attribute_backend_types
      hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attribute_backend_types
    end

    it 'should reset method cache after updating hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_backend_types).twice

      Product.hydra_attribute_backend_types
      hydra_attribute.update_attributes(name: 'two')
      Product.hydra_attribute_backend_types
    end

    it 'should reset method cache after removing hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'once', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_backend_types).twice

      Product.hydra_attribute_backend_types
      hydra_attribute.destroy
      Product.hydra_attribute_backend_types
    end
  end

  describe '.hydra_attribute_ids' do
    it 'should return all ids' do
      one   = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      two   = Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      three = Product.hydra_attributes.create(name: 'three', backend_type: 'integer')

      Product.hydra_attribute_ids.should =~ [one.id, two.id, three.id]
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_attribute_ids).once
      2.times { Product.hydra_attribute_ids }
    end

    it 'should reset method cache after creating hydra attribute' do
      hydra_attributes = Product.hydra_attributes
      Product.should_receive(:unmemoized_hydra_attribute_ids).twice

      Product.hydra_attribute_ids
      hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attribute_ids
    end

    it 'should reset method cache after updating hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_ids).twice

      Product.hydra_attribute_ids
      hydra_attribute.update_attributes(name: 'two')
      Product.hydra_attribute_ids
    end

    it 'should reset method cache after removing hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'once', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_ids).twice

      Product.hydra_attribute_ids
      hydra_attribute.destroy
      Product.hydra_attribute_ids
    end
  end

  describe '.hydra_attribute_names' do
    it 'should return names' do
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      Product.hydra_attributes.create(name: 'three', backend_type: 'integer')

      Product.hydra_attribute_names.should =~ %w(one two three)
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_attribute_names).once
      2.times { Product.hydra_attribute_names }
    end

    it 'should reset method cache after creating hydra attribute' do
      hydra_attributes = Product.hydra_attributes
      Product.should_receive(:unmemoized_hydra_attribute_names).twice

      Product.hydra_attribute_names
      hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attribute_names
    end

    it 'should reset method cache after updating hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_names).twice

      Product.hydra_attribute_names
      hydra_attribute.update_attributes(name: 'two')
      Product.hydra_attribute_names
    end

    it 'should reset method cache after removing hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'once', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_names).twice

      Product.hydra_attribute_names
      hydra_attribute.destroy
      Product.hydra_attribute_names
    end
  end

  describe '.hydra_attributes_by_backend_type' do
    it 'should group attributes by backend type' do
      one   = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      two   = Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      three = Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      four  = Product.hydra_attributes.create(name: 'four', backend_type: 'float')

      attributes = Product.hydra_attributes_by_backend_type
      attributes['string'].should  =~ [one, two]
      attributes['integer'].should == [three]
      attributes['float'].should   == [four]
    end

    it 'should return blank hash if there are not any attributes' do
      Product.hydra_attributes_by_backend_type.should == {}
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_attributes_by_backend_type).once
      2.times { Product.hydra_attributes_by_backend_type }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_attributes_by_backend_type).twice

      Product.hydra_attributes_by_backend_type
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attributes_by_backend_type
    end

    it 'should reset method cache after updating hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attributes_by_backend_type).twice

      Product.hydra_attributes_by_backend_type
      one.update_attributes(name: 'two')
      Product.hydra_attributes_by_backend_type
    end

    it 'should reset method cache after removing hydra attribute' do
      one = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attributes_by_backend_type).twice

      Product.hydra_attributes_by_backend_type
      one.destroy
      Product.hydra_attributes_by_backend_type
    end
  end

  describe '.hydra_attribute_ids_by_backend_type' do
    it 'should group attribute ids by backend type' do
      one   = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      two   = Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      three = Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      four  = Product.hydra_attributes.create(name: 'four', backend_type: 'float')

      attributes = Product.hydra_attribute_ids_by_backend_type
      attributes['string'].should  =~ [one.id, two.id]
      attributes['integer'].should == [three.id]
      attributes['float'].should   == [four.id]
    end

    it 'should return blank hash if there are not any attributes' do
      Product.hydra_attribute_ids_by_backend_type.should == {}
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_attribute_ids_by_backend_type).once
      2.times { Product.hydra_attribute_ids_by_backend_type }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_attribute_ids_by_backend_type).twice

      Product.hydra_attribute_ids_by_backend_type
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attribute_ids_by_backend_type
    end

    it 'should reset method cache after updating hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_ids_by_backend_type).twice

      Product.hydra_attribute_ids_by_backend_type
      hydra_attribute.update_attributes(name: 'two')
      Product.hydra_attribute_ids_by_backend_type
    end

    it 'should reset method cache after removing hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_ids_by_backend_type).twice

      Product.hydra_attribute_ids_by_backend_type
      hydra_attribute.destroy
      Product.hydra_attribute_ids_by_backend_type
    end
  end

  describe '.hydra_attribute_names_by_backend_type' do
    it 'should group attribute names by backend type' do
      one   = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      two   = Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      three = Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      four  = Product.hydra_attributes.create(name: 'four', backend_type: 'float')

      attributes = Product.hydra_attribute_names_by_backend_type
      attributes['string'].should  =~ [one.name, two.name]
      attributes['integer'].should == [three.name]
      attributes['float'].should   == [four.name]
    end

    it 'should return blank hash if there are not any attributes' do
      Product.hydra_attribute_names_by_backend_type.should == {}
    end

    it 'should cache result' do
      Product.should_receive(:unmemoized_hydra_attribute_names_by_backend_type).once
      2.times { Product.hydra_attribute_names_by_backend_type }
    end

    it 'should reset method cache after creating hydra attribute' do
      Product.should_receive(:unmemoized_hydra_attribute_names_by_backend_type).twice

      Product.hydra_attribute_names_by_backend_type
      Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.hydra_attribute_names_by_backend_type
    end

    it 'should reset method cache after updating hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_names_by_backend_type).twice

      Product.hydra_attribute_names_by_backend_type
      hydra_attribute.update_attributes(name: 'two')
      Product.hydra_attribute_names_by_backend_type
    end

    it 'should reset method cache after removing hydra attribute' do
      hydra_attribute = Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      Product.should_receive(:unmemoized_hydra_attribute_names_by_backend_type).twice

      Product.hydra_attribute_names_by_backend_type
      hydra_attribute.destroy
      Product.hydra_attribute_names_by_backend_type
    end
  end

  describe '.hydra_attributes_for_backend_type' do
    it 'should return hydra attributes for specific backend type' do
      a1 = Product.hydra_attributes.create(name: 'a1', backend_type: 'string')
      a2 = Product.hydra_attributes.create(name: 'a2', backend_type: 'string')
      a3 = Product.hydra_attributes.create(name: 'a3', backend_type: 'integer')
      a4 = Product.hydra_attributes.create(name: 'a4', backend_type: 'integer')

      Product.hydra_attributes_for_backend_type('string').should  =~ [a1, a2]
      Product.hydra_attributes_for_backend_type('integer').should =~ [a3, a4]
    end

    it 'should return blank array if there are not any hydra attributes' do
      Product.hydra_attributes_for_backend_type('string').should == []
    end
  end

  describe '.hydra_attribute_ids_for_backend_type' do
    it 'should return hydra attribute ids for specific backend type' do
      a1 = Product.hydra_attributes.create(name: 'a1', backend_type: 'string')
      a2 = Product.hydra_attributes.create(name: 'a2', backend_type: 'string')
      a3 = Product.hydra_attributes.create(name: 'a3', backend_type: 'integer')
      a4 = Product.hydra_attributes.create(name: 'a4', backend_type: 'integer')

      Product.hydra_attribute_ids_for_backend_type('string').should  =~ [a1.id, a2.id]
      Product.hydra_attribute_ids_for_backend_type('integer').should =~ [a3.id, a4.id]
    end

    it 'should return blank array if there are not any hydra attributes' do
      Product.hydra_attribute_ids_for_backend_type('string').should == []
    end
  end

  describe '.hydra_attribute_names_for_backend_type' do
    it 'should return hydra attribute names for specific backend type' do
      a1 = Product.hydra_attributes.create(name: 'a1', backend_type: 'string')
      a2 = Product.hydra_attributes.create(name: 'a2', backend_type: 'string')
      a3 = Product.hydra_attributes.create(name: 'a3', backend_type: 'integer')
      a4 = Product.hydra_attributes.create(name: 'a4', backend_type: 'integer')

      Product.hydra_attribute_names_for_backend_type('string').should  =~ [a1.name, a2.name]
      Product.hydra_attribute_names_for_backend_type('integer').should =~ [a3.name, a4.name]
    end

    it 'should return blank array if there are not any hydra attributes' do
      Product.hydra_attribute_names_for_backend_type('string').should == []
    end
  end

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

      it 'should return hydra attribute names for specific hydra set' do
        Product.hydra_set_attribute_backend_types(hydra_set.id).should have(1).hydra_attribute
        Product.hydra_set_attribute_backend_types(hydra_set.id).first.should == hydra_attribute1.backend_type
      end

      it 'should return all hydra attribute names if hydra set does not exist' do
        Product.hydra_set_attribute_backend_types(0).should have(2).hydra_attributes
        Product.hydra_set_attribute_backend_types(0).first.should == hydra_attribute1.backend_type
        Product.hydra_set_attribute_backend_types(0).last.should  == hydra_attribute2.backend_type
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

  describe '.clear_hydra_attribute_cache!' do
    it 'should reset cache for all methods' do
      # Force clear cache because some methods
      # can be already cached during initialization hydra_attribute gem
      Product.clear_hydra_attribute_cache!

      [
        :unmemoized_hydra_attributes,
        :unmemoized_hydra_attribute,
        :unmemoized_hydra_attribute_backend_types,
        :unmemoized_hydra_attribute_ids,
        :unmemoized_hydra_attribute_names,
        :unmemoized_hydra_attributes_by_backend_type,
        :unmemoized_hydra_attribute_ids_by_backend_type,
        :unmemoized_hydra_attribute_names_by_backend_type,
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
        Product.hydra_attributes
        Product.hydra_attribute(1)
        Product.hydra_attribute_backend_types
        Product.hydra_attribute_ids
        Product.hydra_attribute_names
        Product.hydra_attributes_by_backend_type
        Product.hydra_attribute_ids_by_backend_type
        Product.hydra_attribute_names_by_backend_type
        Product.hydra_set_attribute_ids(1)
        Product.hydra_set_attribute_names(1)
        Product.hydra_set_attribute_backend_types(1)
        Product.hydra_set_attributes_by_backend_type(1)
        Product.hydra_set_attribute_ids_by_backend_type(1)
        Product.hydra_set_attribute_names_by_backend_type(1)
      end

      block.call
      Product.clear_hydra_attribute_cache!
      block.call
    end
  end
end