require 'spec_helper'

describe HydraAttribute::Model do
  before(:all) do
    ::ActiveRecord::Base.connection.create_table(:custom_products) do |t|
      t.string  :name
      t.float   :price
      t.integer :quantity
    end
    Object.const_set('CustomProduct', Class.new)
    CustomProduct.send(:include, HydraAttribute::Model)
  end

  after(:all) do
    ::ActiveRecord::Base.connection.drop_table(:custom_products)
    Object.send(:remove_const, 'CustomProduct')
  end

  describe '.connection' do
    it 'should return database adapter object' do
      CustomProduct.connection.should == ActiveRecord::Base.connection
    end
  end

  describe '.table_name' do
    it 'should determine table name based on class name' do
      CustomProduct.table_name.should == 'custom_products'
    end
  end

  describe '.arel_table' do
    it 'should build arel table for class' do
      arel_table = CustomProduct.arel_table
      arel_table.should be_a_kind_of(Arel::Table)
      arel_table.table_name.should  == 'custom_products'
      arel_table.engine.should      == CustomProduct
    end
  end

  describe '.all' do
    it 'should return blank array if table is empty' do
      CustomProduct.all.should == []
    end

    it 'should return array of models if table has records' do
      query  = 'INSERT INTO custom_products (name, price, quantity) '
      query += 'VALUES ("one", 2.5, 5), ("two", 3.5, 6)'
      ActiveRecord::Base.connection.exec_query(query)

      all = CustomProduct.all
      all.should have(2).items

      all[0].should be_a_kind_of(CustomProduct)
      all[0].attributes['name'].should     == 'one'
      all[0].attributes['price'].should    == 2.5
      all[0].attributes['quantity'].should == 5

      all[1].should be_a_kind_of(CustomProduct)
      all[1].attributes['name'].should     == 'two'
      all[1].attributes['price'].should    == 3.5
      all[1].attributes['quantity'].should == 6
    end
  end

  describe '.find' do
    it 'should return nil if cannot find a record' do
      CustomProduct.find(1).should be_nil
    end

    it 'should return model if record exists' do
      query  = 'INSERT INTO custom_products (id, name, price, quantity) '
      query += 'VALUES (1, "book", 2.2, 3)'
      ActiveRecord::Base.connection.exec_query(query)

      model = CustomProduct.find(1)
      model.should be_a_kind_of(CustomProduct)
      model.attributes['id'].should       == 1
      model.attributes['name'].should     == 'book'
      model.attributes['price'].should    == 2.2
      model.attributes['quantity'].should == 3
    end
  end

  describe '.where' do
    describe 'table is blank' do
      it 'should return blank array' do
        CustomProduct.where.should be_blank
      end
    end

    describe 'table has records' do
      before(:each) do
        query  = 'INSERT INTO custom_products (id, name, price, quantity) '
        query += 'VALUES (1, "one", 1.1, 2), (2, "two", 2.2, 2), (3, "three", 3.3, 4)'
        ActiveRecord::Base.connection.exec_query(query)
      end

      it 'should return blank array if records do not match condition' do
        CustomProduct.where(id: 4).should be_blank
      end

      it 'should select records which match condition' do
        records = CustomProduct.where(quantity: 2, price: 2.2)
        records.should have(1).item
        records[0].attributes['id'].should       == 2
        records[0].attributes['name'].should     == 'two'
        records[0].attributes['price'].should    == 2.2
        records[0].attributes['quantity'].should == 2
      end

      it 'should select certain columns' do
        records = CustomProduct.where({quantity: 2}, %w[id name])
        records.should have(2).items

        records[0].attributes['id'].should       == 1
        records[0].attributes['name'].should     == 'one'
        records[0].attributes['price'].should    == nil
        records[0].attributes['quantity'].should == nil

        records[1].attributes['id'].should       == 2
        records[1].attributes['name'].should     == 'two'
        records[1].attributes['price'].should    == nil
        records[1].attributes['quantity'].should == nil
      end

      it 'should limit records' do
        records = CustomProduct.where({}, 'id', 2)
        records.should have(2).times
        records[0].attributes['id'].should == 1
      end

      it 'should skip records' do
        records = CustomProduct.where({}, 'id', nil, 1)
        records.should have(2).times
        records[0].attributes['id'].should == 2
      end
    end
  end

  describe '.create' do
    it 'should create record and return ID of this record' do
      id     = CustomProduct.create(name: 'apple', price: 2.50, quantity: 5)
      result = ActiveRecord::Base.connection.select_one("SELECT * FROM custom_products WHERE id=#{id}")

      result['name'].should     == 'apple'
      result['price'].should    == 2.50
      result['quantity'].should == 5
    end
  end

  describe '.update' do
    it 'should update record by its ID' do
      query  = 'INSERT INTO custom_products (id, name, price, quantity) '
      query += 'VALUES (1, "one", 1.1, 2)'
      ActiveRecord::Base.connection.exec_query(query)

      CustomProduct.update(1, name: 'book', price: 2.5)

      result = ActiveRecord::Base.connection.select_one('SELECT * FROM custom_products WHERE id=1')
      result['id'].should       == 1
      result['name'].should     == 'book'
      result['price'].should    == 2.5
      result['quantity'].should == 2
    end
  end
end