require 'spec_helper'

describe HydraAttribute::Model::Cache do
  before(:all) do
    ::ActiveRecord::Base.connection.create_table(:custom_products) do |t|
      t.string  :name
      t.float   :price
      t.integer :quantity
    end
    Object.const_set('CustomProduct', Class.new)
    CustomProduct.send(:include, HydraAttribute::Model::Validations) # dependency
    CustomProduct.send(:include, HydraAttribute::Model::Mediator)    # dependency
    CustomProduct.send(:include, HydraAttribute::Model::Persistence) # dependency
    CustomProduct.send(:include, HydraAttribute::Model::IdentityMap) # dependency
    CustomProduct.send(:include, HydraAttribute::Model::Cache)
  end

  after(:all) do
    ::ActiveRecord::Base.connection.drop_table(:custom_products)
    Object.send(:remove_const, 'CustomProduct')
  end

  describe '.all' do
    it 'should find all models and store them into the cache' do
      q1 = %[INSERT INTO "custom_products" ("name", "price", "quantity") VALUES ('one', 2.5, 5)]
      q2 = %[INSERT INTO "custom_products" ("name", "price", "quantity") VALUES ('two', 3.5, 6)]

      ActiveRecord::Base.connection.exec_query(q1)
      ActiveRecord::Base.connection.exec_query(q2)

      all = CustomProduct.all
      all.should have(2).records

      all.first.name.should  == 'one'
      all.last.name.should   == 'two'

      CustomProduct.identity_map[:all].should == all
    end

    it 'should hit database once' do
      connection = ActiveRecord::Base.connection
      CustomProduct.should_receive(:connection).once.and_return(connection)
      2.times { CustomProduct.all }
    end
  end

  describe '.find' do
    it 'should load all records and find the right one from the cache' do
      q1 = %[INSERT INTO "custom_products" ("name", "price", "quantity") VALUES ('one', 2.5, 5)]
      q2 = %[INSERT INTO "custom_products" ("name", "price", "quantity") VALUES ('two', 3.5, 6)]

      id1 = ActiveRecord::Base.connection.insert(q1)
      id2 = ActiveRecord::Base.connection.insert(q2)

      CustomProduct.identity_map[:all].should be_nil
      record = CustomProduct.find(id1)
      record.name.should == 'one'

      CustomProduct.identity_map[:all].should have(2).records
      CustomProduct.identity_map[:all][0].id.should be(id1)
      CustomProduct.identity_map[:all][1].id.should be(id2)
    end

    it 'should raise an error if cannot find the record' do
      lambda do
        CustomProduct.find(1)
      end.should raise_error(HydraAttribute::RecordNotFound, "Couldn't find CustomProduct with id=1")
    end
  end

  describe '#initialize' do
    it 'should store model into the cache if it has an ID' do
      product1 = CustomProduct.new(id: 1)
      product2 = CustomProduct.new(id: 2)
      CustomProduct.model_identity_map[1].should be(product1)
      CustomProduct.model_identity_map[2].should be(product2)
    end

    it 'should not store model into the cache if it has not an ID' do
      CustomProduct.new
      CustomProduct.model_identity_map.should be_empty
    end

    it 'should not add model to the :all cache key' do
      CustomProduct.new(id: 1)
      CustomProduct.identity_map[:all].should be_nil
    end
  end

  describe '#save' do
    it 'should add model to the cache if it was a new model' do
      product = CustomProduct.new
      product.save
      CustomProduct.model_identity_map[product.id].should be(product)
    end

    it 'should not add model to the :all cache key if all models were not loaded before' do
      CustomProduct.new.save
      CustomProduct.identity_map[:all].should be_nil
    end

    it 'should add model to the :all cache key if all models were were loaded before' do
      CustomProduct.all
      product = CustomProduct.new
      product.save
      CustomProduct.identity_map[:all].should include(product)
    end
  end

  describe '#destroy' do
    it 'should remove model from the cache' do
      product = CustomProduct.new
      product.save
      product.destroy
      CustomProduct.model_identity_map[product.id].should be_nil
    end

    it 'should remove model from the :all cache' do
      CustomProduct.all
      product = CustomProduct.new
      product.save
      product.destroy
      CustomProduct.identity_map[:all].should_not include(product)
    end
  end
end