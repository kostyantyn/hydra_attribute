require 'spec_helper'

describe HydraAttribute::Model::Persistence do
  before(:all) do
    ::ActiveRecord::Base.connection.create_table(:custom_products) do |t|
      t.string  :name
      t.decimal :price, precision: 4, scale: 2
      t.integer :quantity
      t.timestamps
    end
    Object.const_set('CustomProduct', Class.new)
    CustomProduct.send(:include, HydraAttribute::Model::Validations) # dependency
    CustomProduct.send(:include, HydraAttribute::Model::Persistence)
  end

  after(:all) do
    ::ActiveRecord::Base.connection.drop_table(:custom_products)
    Object.send(:remove_const, 'CustomProduct')
  end

  describe '.define_attribute_methods' do
    before do
      ::ActiveRecord::Base.connection.create_table(:example_products) do |t|
        t.string  :title
        t.float   :price
        t.integer :count
        t.timestamps
      end
      Object.const_set('ExampleProduct', Class.new)
      ExampleProduct.send(:include, HydraAttribute::Model::Persistence)
    end

    after do
      ::ActiveRecord::Base.connection.drop_table(:example_products)
      Object.send(:remove_const, 'ExampleProduct')
    end

    it 'should generate attribute setter and getter' do
      methods = [:title, :title=, :price, :price=, :count, :count=]
      methods.each do |method|
        ExampleProduct.method_defined?(method).should be_false
      end

      ExampleProduct.define_attribute_methods

      methods.each do |method|
        ExampleProduct.method_defined?(method).should be_true
      end
    end
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

  describe '.columns' do
    it 'should return collection of objects which represent table columns' do
      CustomProduct.should have(6).columns
      CustomProduct.columns.each do |column|
        column.should be_a_kind_of(ActiveRecord::ConnectionAdapters::Column)
      end
    end
  end

  describe '.column' do
    it 'should return object which represents table column' do
      CustomProduct.column('name').should be_a_kind_of(ActiveRecord::ConnectionAdapters::Column)
    end
  end

  describe '.column_names' do
    it 'should return all column names in table' do
      CustomProduct.column_names.should == %w[id name price quantity created_at updated_at]
    end
  end

  describe '.all' do
    it 'should return blank array if table is empty' do
      CustomProduct.all.should == []
    end

    it 'should return array of models if table has records' do
      q1 = %[INSERT INTO custom_products (name, price, quantity, created_at, updated_at) VALUES ('one', 2.5, 5, '2012-12-12', '2012-12-12')]
      q2 = %[INSERT INTO custom_products (name, price, quantity, created_at, updated_at) VALUES ('two', 3.5, 6, '2012-12-12', '2012-12-12')]

      ActiveRecord::Base.connection.execute(q1)
      ActiveRecord::Base.connection.execute(q2)

      all = CustomProduct.all
      all.should have(2).items

      all[0].should be_a_kind_of(CustomProduct)
      all[0].name.should     == 'one'
      all[0].price.should    == 2.5
      all[0].quantity.should == 5

      all[1].should be_a_kind_of(CustomProduct)
      all[1].name.should     == 'two'
      all[1].price.should    == 3.5
      all[1].quantity.should == 6
    end
  end

  describe '.find' do
    it 'should raise HydraAttribute::RecordNotFound if cannot find a record' do
      lambda do
        CustomProduct.find(1)
      end.should raise_error(HydraAttribute::RecordNotFound, %q(Couldn't find CustomProduct with id=1))
    end

    it 'should return model if record exists' do
      q1 = %[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (1, 'book', 2.2, 3, '2012-12-12', '2012-12-12')]
      ActiveRecord::Base.connection.execute(q1)

      model = CustomProduct.find(1)
      model.should be_a_kind_of(CustomProduct)
      model.id.should       == 1
      model.name.should     == 'book'
      model.price.should    == 2.2
      model.quantity.should == 3
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
        q1 = %[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (1, 'one', 1.1, 2, '2012-12-12', '2012-12-12')]
        q2 = %[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (2, 'two', 2.2, 2, '2012-12-12', '2012-12-12')]
        q3 = %[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (3, 'three', 3.3, 4, '2012-12-12', '2012-12-12')]

        ActiveRecord::Base.connection.execute(q1)
        ActiveRecord::Base.connection.execute(q2)
        ActiveRecord::Base.connection.execute(q3)
      end

      it 'should return blank array if records do not match condition' do
        CustomProduct.where(id: 4).should be_blank
      end

      it 'should select records which match condition' do
        records = CustomProduct.where(quantity: 2, price: 2.2)
        records.should have(1).item
        records[0].id.should       == 2
        records[0].name.should     == 'two'
        records[0].price.should    == 2.2
        records[0].quantity.should == 2
      end

      it 'should select records by collection of values' do
        records = CustomProduct.where(id: [1, 2])
        records.should have(2).items

        records[0].id.should       == 1
        records[0].name.should     == 'one'
        records[0].price.should    == 1.1
        records[0].quantity.should == 2

        records[1].id.should       == 2
        records[1].name.should     == 'two'
        records[1].price.should    == 2.2
        records[1].quantity.should == 2
      end

      it 'should select certain columns' do
        records = CustomProduct.where({quantity: 2}, %w[id name])
        records.should have(2).items

        records[0].id.should       == 1
        records[0].name.should     == 'one'
        records[0].price.should    == nil
        records[0].quantity.should == nil

        records[1].id.should       == 2
        records[1].name.should     == 'two'
        records[1].price.should    == nil
        records[1].quantity.should == nil
      end

      it 'should limit records' do
        records = CustomProduct.where({}, 'id', 2)
        records.should have(2).times
        records[0].id.should == 1
      end

      it 'should skip records' do
        records = CustomProduct.where({}, 'id', nil, 1)
        records.should have(2).times
        records[0].id.should == 2
      end
    end
  end

  describe '.where_not' do
    describe 'table is blank' do
      it 'should return blank array' do
        CustomProduct.where_not.should be_blank
      end
    end

    describe 'table has records' do
      before(:each) do
        q1 = %q[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (1, 'one', 1.1, 2, '2012-12-12', '2012-12-12')]
        q2 = %q[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (2, 'two', 2.2, 2, '2012-12-12', '2012-12-12')]
        q3 = %q[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (3, 'three', 3.3, 4, '2012-12-12', '2012-12-12')]

        ActiveRecord::Base.connection.execute(q1)
        ActiveRecord::Base.connection.execute(q2)
        ActiveRecord::Base.connection.execute(q3)
      end

      it 'should return models which does not match condition' do
        records = CustomProduct.where_not(id: 1)
        records.should have(2).items

        records[0].id.should == 2
        records[1].id.should == 3
      end

      it 'should accept array of values in query' do
        records = CustomProduct.where_not(id: [1, 3])
        records.should have(1).items

        records[0].id.should == 2
      end
    end
  end

  describe '.create' do
    it 'should create record and return ID of this record' do
      model  = CustomProduct.create(name: 'apple', price: 2.50, quantity: 5)
      result = ActiveRecord::Base.connection.select_one(%[SELECT * FROM custom_products WHERE id=#{model.id}])

      result['name'].should          == 'apple'
      result['price'].to_f.should    == 2.50
      result['quantity'].to_i.should == 5
    end
  end

  describe '.update' do
    it 'should update record by its ID' do
      q = %[INSERT INTO custom_products (id, name, price, quantity, created_at, updated_at) VALUES (1, 'one', 1.1, 2, '2012-12-12', '2012-12-12')]
      ActiveRecord::Base.connection.execute(q)

      CustomProduct.update(1, name: 'book', price: 2.5)

      result = ActiveRecord::Base.connection.select_one(%[SELECT * FROM custom_products WHERE id=1])
      result['id'].to_i.should       == 1
      result['name'].should          == 'book'
      result['price'].to_f.should    == 2.5
      result['quantity'].to_i.should == 2
    end
  end

  describe '.destroy' do
    let!(:attr1) { Product.hydra_attributes.create(name: 'a1', backend_type: 'string') }
    let!(:attr2) { Product.hydra_attributes.create(name: 'a2', backend_type: 'string') }

    it 'should destroy model by ID' do
      lambda { HydraAttribute::HydraAttribute.find(attr1.id) }.should_not raise_error
      lambda { HydraAttribute::HydraAttribute.find(attr2.id) }.should_not raise_error

      HydraAttribute::HydraAttribute.destroy(attr1.id)

      lambda { HydraAttribute::HydraAttribute.find(attr1.id) }.should     raise_error(HydraAttribute::RecordNotFound)
      lambda { HydraAttribute::HydraAttribute.find(attr2.id) }.should_not raise_error

      HydraAttribute::HydraAttribute.destroy(attr2.id)

      lambda { HydraAttribute::HydraAttribute.find(attr1.id) }.should raise_error(HydraAttribute::RecordNotFound)
      lambda { HydraAttribute::HydraAttribute.find(attr2.id) }.should raise_error(HydraAttribute::RecordNotFound)
    end
  end

  describe '.destroy_all' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a1', backend_type: 'string') }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a2', backend_type: 'string') }
    let!(:attr3) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'a3', backend_type: 'string') }

    it 'should delete all models' do
      HydraAttribute::HydraAttribute.count.should be(3)
      HydraAttribute::HydraAttribute.destroy_all
      HydraAttribute::HydraAttribute.count.should be(0)
    end

    it 'should return result for every deleted object' do
      result = HydraAttribute::HydraAttribute.destroy_all
      result.should == {attr1.id => true, attr2.id => true, attr3.id => true}
    end
  end

  describe '#attributes' do
    it 'should return all attributes' do
      product = CustomProduct.new(name: 'a', price: 2)
      product.attributes.should == {id: nil, name: 'a', price: 2, quantity: nil, updated_at: nil, created_at: nil}
    end
  end

  describe '#persisted?' do
    it 'should return true if ID exists' do
      product = CustomProduct.new(id: 1)
      product.should be_persisted
    end

    it 'should return false if ID does not exist' do
      product = CustomProduct.new
      product.should_not be_persisted
    end

    it 'should return false if ID exists but it is nil' do
      product = CustomProduct.new(id: nil)
      product.should_not be_persisted
    end

    it 'should return false if record is destroyed' do
      product = CustomProduct.create(name: 'book')
      product.should be_persisted

      product.destroy
      product.should_not be_persisted
    end
  end

  describe '#destroyed?' do
    it 'should return false for new object' do
      product = CustomProduct.new
      product.should_not be_destroyed
    end

    it 'should return false for created object' do
      product = CustomProduct.create(name: 'book')
      product.should_not be_destroyed
    end

    it 'should return true if object was destroyed' do
      product = CustomProduct.create(name: 'book')
      product.destroy
      product.should be_destroyed
    end
  end

  describe '#save' do
    describe 'create' do
      describe 'when save is succeed' do
        it 'should create blank record' do
          product = CustomProduct.new
          product.save
          product.id.should_not be_nil
          ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM custom_products WHERE id=#{product.id}").to_i.should be(1)
        end

        it 'should create record with several fields' do
          product = CustomProduct.new(name: 'my name', price: 2.50, quantity: 4)
          product.save
          product.id.should_not be_nil

          results = ActiveRecord::Base.connection.select_one("SELECT * FROM custom_products WHERE id=#{product.id}")
          results['id'].to_i.should       == product.id
          results['name'].should          == 'my name'
          results['price'].to_f.should    == 2.50
          results['quantity'].to_i.should == 4
        end
      end

      describe 'when save is failed' do
        before do
          CustomProduct.send(:include, HydraAttribute::Model::Mediator)
          CustomProduct.send(:include, HydraAttribute::Model::Notifiable)

          class CustomObserverClass
            include HydraAttribute::Model::Mediator
            observe 'CustomProduct', after_create: :after_create
            def self.after_create(*) raise Exception, 'Testing rollback' end
          end
        end

        after do
          Object.send(:remove_const, 'CustomObserverClass')
        end

        it 'should not commit insert query if error was raised during saving' do
          lambda { CustomProduct.new.save }.should raise_error(Exception, 'Testing rollback')
          CustomProduct.connection.select_value('SELECT COUNT(*) FROM custom_products').to_i.should be(0)
        end
      end
    end

    describe 'update' do
      describe 'when save is succeed' do
        it 'should update record if id exists' do
          ActiveRecord::Base.connection.insert(%q[INSERT INTO custom_products(id, name, price, quantity, created_at, updated_at) VALUES (1, 'book', 35.5, 6, '2012-12-12', '2012-12-12')])

          product = CustomProduct.new(id: 1, name: 'book 2', price: 45.7, quantity: 10)
          product.save

          results = ActiveRecord::Base.connection.select_one("SELECT * FROM custom_products WHERE id=#{product.id}")
          results['id'].to_i.should       == product.id
          results['name'].should          == 'book 2'
          results['price'].to_f.should    == 45.7
          results['quantity'].to_i.should == 10
        end
      end

      describe 'when save is failed' do
        before do
          CustomProduct.send(:include, HydraAttribute::Model::Mediator)
          CustomProduct.send(:include, HydraAttribute::Model::Notifiable)

          class CustomObserverClass
            include HydraAttribute::Model::Mediator
            observe 'CustomProduct', after_update: :after_update
            def self.after_update(*) raise Exception, 'Testing rollback' end
          end
        end

        after do
          Object.send(:remove_const, 'CustomObserverClass')
        end

        it 'should not update record if error was raised during saving' do
          ActiveRecord::Base.connection.insert(%q[INSERT INTO custom_products(id, name, price, quantity, created_at, updated_at) VALUES (1, 'book', 35.5, 6, '2012-12-12', '2012-12-12')])
          lambda { CustomProduct.new(id: 1, name: 'ball').save }.should raise_error(Exception, 'Testing rollback')
          CustomProduct.connection.select_value("SELECT name FROM custom_products WHERE id=1").should == 'book'
        end
      end
    end
  end

  describe '#destroy' do
    describe 'when destroy is succeed' do
      it 'should delete record from database' do
        ActiveRecord::Base.connection.insert(%q[INSERT INTO custom_products(id, created_at, updated_at) VALUES (1, '2012-12-12', '2012-12-12')])
        product = CustomProduct.new(id: 1)
        product.destroy
        ActiveRecord::Base.connection.select_value('SELECT COUNT(*) FROM custom_products WHERE id=1').to_i.should be(0)
      end
    end

    describe 'when destroy is failed' do
      before do
        CustomProduct.send(:include, HydraAttribute::Model::Mediator)
        CustomProduct.send(:include, HydraAttribute::Model::Notifiable)

        class CustomProductObserverClass
          include HydraAttribute::Model::Mediator
          observe 'CustomProduct', after_destroy: :after_destroy
          def self.after_destroy(*) raise Exception, 'Testing rollback' end
        end
      end

      after do
        Object.send(:remove_const, 'CustomProductObserverClass')
      end

      it 'should not commit delete query if error was raised during destroying' do
        ActiveRecord::Base.connection.insert(%q[INSERT INTO custom_products(id, created_at, updated_at) VALUES (1, '2012-12-12', '2012-12-12')])
        product = CustomProduct.new(id: 1)
        lambda { product.destroy }.should raise_error(Exception, 'Testing rollback')
        ActiveRecord::Base.connection.select_value('SELECT COUNT(*) FROM custom_products WHERE id=1').to_i.should be(1)
      end
    end
  end

  describe 'auto generated attribute methods' do
    before do
      ::ActiveRecord::Base.connection.create_table(:example_products) do |t|
        t.string  :title
        t.float   :price
        t.integer :count
        t.timestamps
      end
      Object.const_set('ExampleProduct', Class.new)
      ExampleProduct.send(:include, HydraAttribute::Model)
    end

    after do
      ::ActiveRecord::Base.connection.drop_table(:example_products)
      Object.send(:remove_const, 'ExampleProduct')
    end

    it 'should respond to attribute methods' do
      ExampleProduct.new.should respond_to(:title)
      ExampleProduct.new.should respond_to(:title=)
      ExampleProduct.new.should respond_to(:title?)
      ExampleProduct.new.should respond_to(:price)
      ExampleProduct.new.should respond_to(:price=)
      ExampleProduct.new.should respond_to(:price?)
      ExampleProduct.new.should respond_to(:count)
      ExampleProduct.new.should respond_to(:count=)
      ExampleProduct.new.should respond_to(:count?)
    end

    it 'should get values from attributes' do
      product = ExampleProduct.new(title: 'a', price: 2, count: 3)
      product.title.should == 'a'
      product.price.should == 2
      product.count.should == 3
    end

    it 'should set values to attributes' do
      product = ExampleProduct.new
      product.title = 'b'
      product.price = 3
      product.count = 4

      product.title.should == 'b'
      product.price.should == 3
      product.count.should == 4
    end

    it 'should type cast value before set it' do
      product = ExampleProduct.new
      product.count = '1'
      product.count.should be(1)
    end

    it 'should validate values' do
      product = ExampleProduct.new
      product.title?.should be_false

      product.title = ''
      product.title?.should be_false

      product.title = 'a'
      product.title?.should be_true
    end
  end
end
