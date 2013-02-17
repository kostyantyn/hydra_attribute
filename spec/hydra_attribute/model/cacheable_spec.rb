require 'spec_helper'

describe HydraAttribute::Model::Cacheable do
  before do
    ::ActiveRecord::Base.connection.create_table(:custom_products) do |t|
      t.string  :name
      t.float   :price
      t.integer :quantity
    end
    Object.const_set('CustomProduct', Class.new)
    CustomProduct.send(:include, HydraAttribute::Model::Validations) # dependency
    CustomProduct.send(:include, HydraAttribute::Model::Persistence) # dependency
    CustomProduct.send(:include, HydraAttribute::Model::IdentityMap) # dependency
    CustomProduct.send(:include, HydraAttribute::Model::Cacheable)
  end

  after do
    ::ActiveRecord::Base.connection.drop_table(:custom_products)
    Object.send(:remove_const, 'CustomProduct')
  end

  describe '.all' do
    it 'should find all models and store them into the cache' do
      q1 = %q[INSERT INTO custom_products (name, price, quantity) VALUES ('one', 2.5, 5)]
      q2 = %q[INSERT INTO custom_products (name, price, quantity) VALUES ('two', 3.5, 6)]

      ActiveRecord::Base.connection.execute(q1)
      ActiveRecord::Base.connection.execute(q2)

      all = CustomProduct.all
      all.should have(2).records

      all.first.name.should  == 'one'
      all.last.name.should   == 'two'

      CustomProduct.identity_map[:all].should == all
    end
  end

  describe '.find' do
    it 'should load all records store them to the cache' do
      q1 = %q[INSERT INTO custom_products (name, price, quantity) VALUES ('one', 2.5, 5)]
      q2 = %q[INSERT INTO custom_products (name, price, quantity) VALUES ('two', 3.5, 6)]

      id1 = ActiveRecord::Base.connection.insert(q1)
      id2 = ActiveRecord::Base.connection.insert(q2)

      CustomProduct.identity_map[:all].should be_nil
      record = CustomProduct.find(id1)
      record.name.should == 'one'

      CustomProduct.identity_map[:all].should have(2).records
      CustomProduct.identity_map[:all][0].id.should be(id1.to_i)
      CustomProduct.identity_map[:all][1].id.should be(id2.to_i)

      CustomProduct.nested_identity_map(:model)[id1.to_i].id.should be(id1.to_i)
      CustomProduct.nested_identity_map(:model)[id2.to_i].id.should be(id2.to_i)
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
      CustomProduct.nested_identity_map(:model)[1].should be(product1)
      CustomProduct.nested_identity_map(:model)[2].should be(product2)
    end

    it 'should not store model into the cache if it has not an ID' do
      CustomProduct.new
      CustomProduct.nested_identity_map(:model).should be_empty
    end

    it 'should not add model to the :all cache key' do
      CustomProduct.new(id: 1)
      CustomProduct.identity_map[:all].should be_nil
    end
  end

  describe '#create' do
    it 'should add model to the cache if it was a new model' do
      product = CustomProduct.new
      product.save
      CustomProduct.nested_identity_map(:model)[product.id].should be(product)
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
end