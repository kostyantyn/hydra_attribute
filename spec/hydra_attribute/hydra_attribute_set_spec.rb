require 'spec_helper'

describe HydraAttribute::HydraAttributeSet do
  describe '.hydra_attribute_sets_by_hydra_attribute_id' do
    describe 'hydra_attribute_sets table has several records' do
      let(:hydra_attribute_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'name', 'string')]).to_i }
      let(:hydra_attribute_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'code', 'string')]).to_i }

      let(:hydra_set_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'one')]).to_i }
      let(:hydra_set_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'two')]).to_i }

      before do
        ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id1})])
        ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id2})])
        ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id2})])
      end

      it 'should return models which have a correct hydra_attribute_id' do
        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id1)

        hydra_attribute_sets.should have(2).models
        hydra_attribute_sets.map(&:hydra_set_id).should =~ [hydra_set_id1, hydra_set_id2]

        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id2)
        hydra_attribute_sets.should have(1).model
        hydra_attribute_sets.map(&:hydra_set_id).should == [hydra_set_id2]

        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(0)
        hydra_attribute_sets.should be_blank
      end

      it 'should return model which was created in runtime and has a correct hydra_attribute_id' do
        hydra_set_id        = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'set3').id
        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id1, hydra_set_id: hydra_set_id)

        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id1).should have(3).models
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id1).should include(hydra_attribute_set)

        hydra_set_id        = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'set4').id
        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id1, hydra_set_id: hydra_set_id)

        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id1).should have(4).models
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id1).should include(hydra_attribute_set)
      end

      it 'should not return model which was removed' do
        id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_attribute_id=#{hydra_attribute_id1} LIMIT 1])
        HydraAttribute::HydraAttributeSet.find(id).destroy

        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id1)
        hydra_attribute_sets.should have(1).item
      end
    end

    describe 'hydra_attribute_sets table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(1).should == []
      end

      it 'should return model which was created in runtime and has a correct hydra_set_id' do
        hydra_attribute_id  = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr1', backend_type: 'string').id
        hydra_set_id        = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'set1').id
        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id, hydra_set_id: hydra_set_id)


        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id).should have(1).model
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id).should include(hydra_attribute_set)

        hydra_set_id        = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'set2').id
        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id, hydra_set_id: hydra_set_id)

        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id).should have(2).models
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id).should include(hydra_attribute_set)
      end
    end
  end

  describe '.hydra_attribute_sets_by_hydra_set_id' do
    describe 'hydra_attribute_sets table has several records' do
      let(:hydra_attribute_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'name', 'string')]).to_i }
      let(:hydra_attribute_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'code', 'string')]).to_i }

      let(:hydra_set_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'one')]).to_i }
      let(:hydra_set_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'two')]).to_i }

      before do
        ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id1})])
        ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id1})])
        ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id2})])
      end

      it 'should return models which have a correct hydra_set_id' do
        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id1)
        hydra_attribute_sets.should have(2).models
        hydra_attribute_sets.map(&:hydra_attribute_id).should == [hydra_attribute_id1, hydra_attribute_id2]

        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id2)
        hydra_attribute_sets.should have(1).model
        hydra_attribute_sets.map(&:hydra_attribute_id).should == [hydra_attribute_id2]

        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(0)
        hydra_attribute_sets.should be_blank
      end

      it 'should return model which was created in runtime and has a correct hydra_set_id' do
        hydra_attribute_id  = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a3', backend_type: 'string').id
        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id, hydra_set_id: hydra_set_id1)
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id1).should have(3).models
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id1).should include(hydra_attribute_set)

        hydra_attribute_id  = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a4', backend_type: 'string').id
        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id, hydra_set_id: hydra_set_id1)
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id1).should have(4).models
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id1).should include(hydra_attribute_set)
      end

      it 'should not return model which was removed' do
        id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_set_id=#{hydra_set_id1} LIMIT 1])
        HydraAttribute::HydraAttributeSet.find(id).destroy

        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id1)
        hydra_attribute_sets.should have(1).item
      end
    end

    describe 'hydra_attribute_sets table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(1).should == []
      end

      it 'should return model which was created in runtime and has a correct hydra_set_id' do
        hydra_set_id        = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 's1').id
        hydra_attribute_id  = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a1', backend_type: 'string').id

        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id, hydra_set_id: hydra_set_id)
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id).should have(1).model
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id).should include(hydra_attribute_set)

        hydra_attribute_id  = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a2', backend_type: 'string').id
        hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id, hydra_set_id: hydra_set_id)
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id).should have(2).models
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set_id).should include(hydra_attribute_set)
      end
    end
  end

  describe '.hydra_attributes_by_hydra_set_id' do
    describe 'hydra_attribute_sets table has several records' do
      let(:hydra_set_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'one')]).to_i }
      let(:hydra_set_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'two')]).to_i }

      let(:hydra_attribute_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'name', 'string')]).to_i }
      let(:hydra_attribute_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'code', 'string')]).to_i }

      before do
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id1})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id1})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id2})")
      end

      it 'should return hydra_attribute models which assigned to the correct hydra_set_id' do
        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(hydra_set_id1)
        hydra_attributes.should have(2).models
        hydra_attributes.map(&:name).should =~ %w[name code]

        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(hydra_set_id2)
        hydra_attributes.should have(1).model
        hydra_attributes.map(&:name).should =~ %w[code]

        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(0)
        hydra_attributes.should be_blank
      end

      it 'should return hydra_attribute models which were created in runtime and are assigned to the correct hydra_set_id' do
        hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set_id1)

        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(hydra_set_id1)
        hydra_attributes.should have(3).models
        hydra_attributes.map(&:name).should =~ %w[name code title]

        hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'quantity', backend_type: 'integer')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set_id1)

        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(hydra_set_id1)
        hydra_attributes.should have(4).models
        hydra_attributes.map(&:name).should =~ %w[name code title quantity]
      end

      it 'should not return model which was removed' do
        id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_attribute_id=#{hydra_attribute_id1} AND hydra_set_id=#{hydra_set_id1}])
        HydraAttribute::HydraAttributeSet.find(id).destroy

        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(hydra_set_id1)
        hydra_attributes.should have(1).item
        hydra_attributes[0].name.should == 'code'
      end
    end

    describe 'hydra_attribute_sets table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(1).should == []
      end

      it 'should return hydra_attribute models which were created in runtime and are assigned to the correct hydra_set_id' do
        hydra_set_id    = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'set1').id
        hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set_id)

        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(hydra_set_id)
        hydra_attributes.should have(1).model
        hydra_attributes.map(&:name).should =~ %w[title]

        hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'quantity', backend_type: 'integer')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set_id)

        hydra_attributes = HydraAttribute::HydraAttributeSet.hydra_attributes_by_hydra_set_id(hydra_set_id)
        hydra_attributes.should have(2).models
        hydra_attributes.map(&:name).should =~ %w[title quantity]
      end
    end
  end

  describe '.hydra_sets_by_hydra_attribute_id' do
    describe 'hydra_attribute_sets table has several records' do
      let(:hydra_set_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'one')]).to_i }
      let(:hydra_set_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'two')]).to_i }

      let(:hydra_attribute_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'name', 'string')]).to_i }
      let(:hydra_attribute_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'code', 'string')]).to_i }

      before do
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id1})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id2})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id2})")
      end

      it 'should return hydra_set models which assigned to the correct hydra_attribute_id' do
        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(hydra_attribute_id1)
        hydra_sets.should have(2).models
        hydra_sets.map(&:name).should =~ %w[one two]

        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(hydra_attribute_id2)
        hydra_sets.should have(1).model
        hydra_sets.map(&:name).should =~ %w[two]

        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(0)
        hydra_sets.should be_blank
      end

      it 'should return hydra_set models which were created in runtime and are assigned to the correct hydra_attribute_id' do
        hydra_set = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'three')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id1, hydra_set_id: hydra_set.id)

        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(hydra_attribute_id1)
        hydra_sets.should have(3).models
        hydra_sets.map(&:name).should =~ %w[one two three]

        hydra_set = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'four')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute_id1, hydra_set_id: hydra_set.id)

        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(hydra_attribute_id1)
        hydra_sets.should have(4).models
        hydra_sets.map(&:name).should =~ %w[one two three four]
      end

      it 'should not return model which was removed' do
        id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_attribute_id=#{hydra_attribute_id1} AND hydra_set_id=#{hydra_set_id1}])
        HydraAttribute::HydraAttributeSet.find(id).destroy

        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(hydra_attribute_id1)
        hydra_sets.should have(1).item
        hydra_sets[0].name.should == 'two'
      end
    end

    describe 'hydra_attribute_sets table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(1).should == []
      end

      it 'should return hydra_set models which were created in runtime and are assigned to the correct hydra_attribute_id' do
        hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a1', backend_type: 'string')
        hydra_set       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'three')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set.id)

        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(hydra_attribute.id)
        hydra_sets.should have(1).models
        hydra_sets.map(&:name).should =~ %w[three]

        hydra_set = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'four')
        HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set.id)

        hydra_sets = HydraAttribute::HydraAttributeSet.hydra_sets_by_hydra_attribute_id(hydra_attribute.id)
        hydra_sets.should have(2).models
        hydra_sets.map(&:name).should =~ %w[three four]
      end
    end
  end

  describe '.hydra_attribute_ids_by_hydra_set_id' do
    describe 'hydra_attribute_sets table has several records' do
      let(:hydra_set_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'one')]).to_i }
      let(:hydra_set_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'two')]).to_i }

      let(:hydra_attribute_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'name', 'string')]).to_i }
      let(:hydra_attribute_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'code', 'string')]).to_i }

      before do
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id1})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id2})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id2})")
      end

      it 'should return collection of hydra_attribute_id which are assigned to the correct hydra_set_id' do
        HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(hydra_set_id1).should =~ [hydra_attribute_id1]
        HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(hydra_set_id2).should =~ [hydra_attribute_id1, hydra_attribute_id2]
      end

      it 'should return hydra_attribute_ids which were created in runtime and are assigned to the correct hydra_set_id' do
        hydra_attribute_id3 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a1', backend_type: 'string').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id2, hydra_attribute_id: hydra_attribute_id3)
        HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(hydra_set_id2).should =~ [hydra_attribute_id1, hydra_attribute_id2, hydra_attribute_id3]

        hydra_attribute_id4 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a2', backend_type: 'string').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id2, hydra_attribute_id: hydra_attribute_id4)
        HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(hydra_set_id2).should =~ [hydra_attribute_id1, hydra_attribute_id2, hydra_attribute_id3, hydra_attribute_id4]
      end

      it 'should not return hydra_attribute_id if hydra_attribute_set was removed' do
        id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_attribute_id=#{hydra_attribute_id2} AND hydra_set_id=#{hydra_set_id2}])
        HydraAttribute::HydraAttributeSet.find(id).destroy

        hydra_attribute_ids = HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(hydra_set_id2)
        hydra_attribute_ids.should == [hydra_attribute_id1]
      end
    end

    describe 'hydra_attribute_sets table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(1).should == []
      end

      it 'should return hydra_attribute_ids which were created in runtime and are assigned to the correct hydra_set_id' do
        hydra_set_id = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 's1').id

        hydra_attribute_id1 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a1', backend_type: 'string').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: hydra_attribute_id1)
        HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(hydra_set_id).should =~ [hydra_attribute_id1]

        hydra_attribute_id2 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a2', backend_type: 'string').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: hydra_attribute_id2)
        HydraAttribute::HydraAttributeSet.hydra_attribute_ids_by_hydra_set_id(hydra_set_id).should =~ [hydra_attribute_id1, hydra_attribute_id2]
      end
    end
  end

  describe '.hydra_set_ids_by_hydra_attribute_id' do
    describe 'hydra_attribute_sets table has several records' do
      let(:hydra_set_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'one')]).to_i }
      let(:hydra_set_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'two')]).to_i }

      let(:hydra_attribute_id1) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'name', 'string')]).to_i }
      let(:hydra_attribute_id2) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'code', 'string')]).to_i }

      before do
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id1})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id1}, #{hydra_set_id2})")
        ::ActiveRecord::Base.connection.insert("INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id2}, #{hydra_set_id2})")
      end

      it 'should return collection of hydra_set_id which are assigned to the correct hydra_attribute_id' do
        HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id1).should =~ [hydra_set_id1, hydra_set_id2]
        HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id2).should =~ [hydra_set_id2]
      end

      it 'should return hydra_set_ids which were created in runtime and are assigned to the correct hydra_attribute_id' do
        hydra_set_id3 = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 's1').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id3, hydra_attribute_id: hydra_attribute_id1)
        HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id1).should =~ [hydra_set_id1, hydra_set_id2, hydra_set_id3]

        hydra_set_id4 = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 's2').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id4, hydra_attribute_id: hydra_attribute_id1)
        HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id1).should =~ [hydra_set_id1, hydra_set_id2, hydra_set_id3, hydra_set_id4]
      end

      it 'should not return hydra_set_id if hydra_attribute_set was removed' do
        id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_attribute_id=#{hydra_attribute_id1} AND hydra_set_id=#{hydra_set_id1}])
        HydraAttribute::HydraAttributeSet.find(id).destroy

        hydra_set_ids = HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id1)
        hydra_set_ids.should == [hydra_set_id2]
      end
    end

    describe 'hydra_attribute_sets table is blank' do
      it 'should return blank collection' do
        HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(1).should == []
      end

      it 'should return hydra_set_ids which were created in runtime and are assigned to the correct hydra_attribute_id' do
        hydra_set_id1      = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 's1').id
        hydra_attribute_id = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a1', backend_type: 'string').id

        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id1, hydra_attribute_id: hydra_attribute_id)
        HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id).should =~ [hydra_set_id1]

        hydra_set_id2 = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 's2').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id2, hydra_attribute_id: hydra_attribute_id)
        HydraAttribute::HydraAttributeSet.hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id).should =~ [hydra_set_id1, hydra_set_id2]
      end
    end
  end

  describe '.has_hydra_attribute_id_in_hydra_set_id?' do
    let(:hydra_attribute_id) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr', 'string')]).to_i }
    let(:hydra_set_id)       { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'set')]).to_i }

    before do
      ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id}, #{hydra_set_id})])
    end

    it 'should return true if hydra_attribute_id is assigned to hydra_set_id' do
      HydraAttribute::HydraAttributeSet.should have_hydra_attribute_id_in_hydra_set_id(hydra_attribute_id, hydra_set_id)
    end

    it 'should return true if hydra_attribute_id is assigned to hydra_set_id in runtime' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr1', backend_type: 'string')
      hydra_set       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'set1')

      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set.id)
      HydraAttribute::HydraAttributeSet.should have_hydra_attribute_id_in_hydra_set_id(hydra_attribute.id, hydra_set.id)
    end

    it 'should return false if hydra_attribute_id is not assigned to hydra_set_id' do
      HydraAttribute::HydraAttributeSet.should_not have_hydra_attribute_id_in_hydra_set_id(0, 0)
    end

    it 'should return false if hydra_attribute_set was destroyed in runtime' do
      id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_attribute_id=#{hydra_attribute_id} AND hydra_set_id=#{hydra_set_id}])
      HydraAttribute::HydraAttributeSet.find(id).destroy

      HydraAttribute::HydraAttributeSet.should_not have_hydra_attribute_id_in_hydra_set_id(hydra_attribute_id, hydra_set_id)
    end
  end

  describe '.has_hydra_set_id_in_hydra_attribute_id?' do
    let(:hydra_attribute_id) { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_attributes(entity_type, name, backend_type) VALUES('Product', 'attr', 'string')]) }
    let(:hydra_set_id)       { ::ActiveRecord::Base.connection.insert(%q[INSERT INTO hydra_sets(entity_type, name) VALUES('Product', 'set')]) }

    before do
      ::ActiveRecord::Base.connection.insert(%[INSERT INTO hydra_attribute_sets(hydra_attribute_id, hydra_set_id) VALUES(#{hydra_attribute_id}, #{hydra_set_id})])
    end

    it 'should return true if hydra_set_id is assigned to hydra_attribute_id' do
      HydraAttribute::HydraAttributeSet.should have_hydra_set_id_in_hydra_attribute_id(hydra_set_id, hydra_attribute_id)
    end

    it 'should return true if hydra_set_id is assigned to hydra_attribute_id in runtime' do
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr1', backend_type: 'string')
      hydra_set       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'set1')

      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: hydra_attribute.id, hydra_set_id: hydra_set.id)
      HydraAttribute::HydraAttributeSet.should have_hydra_set_id_in_hydra_attribute_id(hydra_set.id, hydra_attribute.id)
    end

    it 'should return false if hydra_set_id is not assigned to hydra_attribute_id' do
      HydraAttribute::HydraAttributeSet.should_not have_hydra_set_id_in_hydra_attribute_id(0, 0)
    end

    it 'should return false if hydra_attribute_set was destroyed in runtime' do
      id = ::ActiveRecord::Base.connection.select_value(%[SELECT id FROM hydra_attribute_sets WHERE hydra_attribute_id=#{hydra_attribute_id} AND hydra_set_id=#{hydra_set_id}])
      HydraAttribute::HydraAttributeSet.find(id).destroy

      HydraAttribute::HydraAttributeSet.should_not have_hydra_set_id_in_hydra_attribute_id(hydra_set_id, hydra_attribute_id)
    end
  end

  describe '#hydra_set' do
    it 'should return HydraSet model if this model is persisted' do
      hydra_set       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default')
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr', backend_type: 'string')

      hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attribute.id)
      hydra_attribute_set.hydra_set.should be(hydra_set)
    end

    it 'should return nil if this model is not persisted' do
      HydraAttribute::HydraAttributeSet.new.hydra_set.should be_nil
    end
  end

  describe '#hydra_attribute' do
    it 'should return HydraAttribute model if this model is persisted' do
      hydra_set       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default')
      hydra_attribute = HydraAttribute::HydraAttribute.create(name: 'title', entity_type: 'Product', backend_type: 'string')

      hydra_attribute_set = HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attribute.id)
      hydra_attribute_set.hydra_attribute.should be(hydra_attribute)
    end

    it 'should return nil if this model is not persisted' do
      HydraAttribute::HydraAttributeSet.new.hydra_attribute.should be_nil
    end
  end

  describe 'callbacks' do
    describe 'hydra_set destroyed' do
      let!(:hydra_set)           { HydraAttribute::HydraSet.create(name: 'default', entity_type: 'Product') }
      let!(:hydra_attribute)     { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string') }
      let!(:hydra_attribute_set) { HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attribute.id) }

      it 'should delete hydra_attribute_set relation from database' do
        hydra_set.destroy
        ::ActiveRecord::Base.connection.select_value(%[SELECT COUNT(*) FROM hydra_attribute_sets WHERE id=#{hydra_attribute_set.id}]).to_i.should be(0)
      end

      it 'should delete hydra_attribute_set relation from cache' do
        hydra_set.destroy
        lambda do
          HydraAttribute::HydraAttributeSet.find(hydra_attribute_set.id)
        end.should raise_error(HydraAttribute::RecordNotFound, "Couldn't find HydraAttribute::HydraAttributeSet with id=#{hydra_attribute_set.id}")
      end

      it 'should delete hydra_set cache' do
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set.id).should include(hydra_attribute_set)
        hydra_set.destroy
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set.id).should be_blank
      end

      it 'should delete hydra_set from hydra_attribute cache' do
        hydra_set2           = HydraAttribute::HydraSet.create(name: 'second', entity_type: 'Product')
        hydra_attribute_set2 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set2.id, hydra_attribute_id: hydra_attribute.id)

        hydra_set.destroy
        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute.id)
        hydra_attribute_sets.should_not include(hydra_attribute_set)
        hydra_attribute_sets.should     include(hydra_attribute_set2)
      end
    end

    describe 'hydra_attribute destroyed' do
      let!(:hydra_set)           { HydraAttribute::HydraSet.create(name: 'default', entity_type: 'Product') }
      let!(:hydra_attribute)     { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string') }
      let!(:hydra_attribute_set) { HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attribute.id) }

      it 'should delete hydra_attribute_set relation from database' do
        hydra_attribute.destroy
        ::ActiveRecord::Base.connection.select_value(%[SELECT COUNT(*) FROM hydra_attribute_sets WHERE id=#{hydra_attribute_set.id}]).to_i.should be(0)
      end

      it 'should delete hydra_attribute_set relation from cache' do
        hydra_set.destroy
        lambda do
          HydraAttribute::HydraAttributeSet.find(hydra_attribute_set.id)
        end.should raise_error(HydraAttribute::RecordNotFound, "Couldn't find HydraAttribute::HydraAttributeSet with id=#{hydra_attribute_set.id}")
      end

      it 'should delete hydra_attribute cache' do
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute.id).should include(hydra_attribute_set)
        hydra_attribute.destroy
        HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute.id).should be_blank
      end

      it 'should delete hydra_attribute from hydra_set cache' do
        hydra_attribute2     = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'string')
        hydra_attribute_set2 = HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attribute2.id)

        hydra_attribute.destroy
        hydra_attribute_sets = HydraAttribute::HydraAttributeSet.hydra_attribute_sets_by_hydra_set_id(hydra_set.id)
        hydra_attribute_sets.should_not include(hydra_attribute_set)
        hydra_attribute_sets.should     include(hydra_attribute_set2)
      end
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
      hydra_set       = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default')
      hydra_attribute = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'attr', backend_type: 'string')

      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attribute.id).should be_persisted
      HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set.id, hydra_attribute_id: hydra_attribute.id).should_not be_persisted
    end
  end
end