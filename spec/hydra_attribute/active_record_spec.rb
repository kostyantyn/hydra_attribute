require 'spec_helper'
require 'data/schema'
require 'data/models'

describe HydraAttribute::ActiveRecord do
  describe 'model should respond to hydra attributes' do
    def build_methods(attrs)
      attrs.map{ |attr| [attr, "#{attr}=", "#{attr}?"] }.flatten
    end

    let(:should_respond_methods)     { build_methods(should_respond)     }
    let(:should_not_respond_methods) { build_methods(should_not_respond) }

    describe 'SimpleProduct' do
      let(:product)            { SimpleProduct.new }
      let(:should_respond)     { %w(name code price active description) }
      let(:should_not_respond) { %w(title total) }

      it 'should respond to own methods' do
        should_respond_methods.each do |method|
          product.should respond_to(method)
        end
      end

      it 'should not respond to methods from other hydra model' do
        should_not_respond_methods.each do |method|
          product.should_not respond_to(method)
        end
      end
    end

    describe 'GroupProduct' do
      let(:product)            { GroupProduct.new }
      let(:should_respond)     { %w(name title price active total) }
      let(:should_not_respond) { %w(code description) }

      it 'should respond to own methods' do
        should_respond_methods.each do |method|
          product.should respond_to(method)
        end
      end

      it 'should not respond to methods from other hydra model' do
        should_not_respond_methods.each do |method|
          product.should_not respond_to(method)
        end
      end
    end
  end

  describe 'model should be built with hydra attributes' do
    describe 'SimpleProduct' do
      let(:attributes) { {name: 'Name', code: '123', active: true, description: 'Description'} }
      let(:product)    { SimpleProduct.new(attributes) }

      it 'should accept all attributes' do
        attributes.each do |name, value|
          product.send(name).should == value
        end
      end
    end

    describe 'GroupProduct' do
      let(:attributes) { {name: 'Name', title: 'title', active: true, total: 2} }
      let(:product)    { GroupProduct.new(attributes) }

      it 'should accept all attributes' do
        attributes.each do |name, value|
          product.send(name).should == value
        end
      end
    end
  end

  describe 'model should be created with hydra attributes' do
    describe 'SimpleProduct' do
      let(:attributes) { {name: 'Name', code: '123', active: true, description: 'Description'} }
      let(:product)    { SimpleProduct.create!(attributes).reload }

      it 'should have all attributes' do
        attributes.each do |name, value|
          product.send(name).should == value
        end
      end
    end

    describe 'GroupProduct' do
      let(:attributes) { {name: 'Name', title: 'title', active: true, total: 2} }
      let(:product)    { GroupProduct.create!(attributes).reload }

      it 'should have all attributes' do
        attributes.each do |name, value|
          product.send(name).should == value
        end
      end
    end
  end

  describe 'typecast attributes' do
    describe 'SimpleProduct' do
      let(:attributes) { {name: 1, code: 2, active: 1, description: 3} }
      let(:product)    { SimpleProduct.create!(attributes).reload }

      it 'should have correct attribute types' do
        product.name.should == '1'
        product.code.should == '2'
        product.active.should be_true
        product.description.should == '3'
      end
    end

    describe 'GroupProduct' do
      let(:attributes) { {name: 1, title: 2, active: 0, total: '3'} }
      let(:product)    { GroupProduct.create!(attributes).reload }

      it 'should have correct attribute types' do
        product.name.should == '1'
        product.title.should == '2'
        product.active.should be_false
        product.total.should == 3
      end
    end
  end

  describe 'collection should not include association models if total records are less than 2' do
    describe 'SimpleProduct' do
      before { SimpleProduct.create(name: 'Name', code: 'Code', price: 2, active: true) }
      it 'should not include associations' do
        product = Product.all.first
        %w(string float boolean).each do |type|
          product.association(HydraAttribute.config.association(type)).should_not be_loaded
        end
      end
    end
  end

  describe 'collection should include association models if total records are more than 1' do
    before do
      SimpleProduct.create(name: 'Name', code: 'Code', price: 2, active: true, description: 'Description')
      GroupProduct.create(name: 'Name', title: 'Title', price: 2, active: true, total: 3)
    end

    let(:products) { Product.all }

    describe 'SimpleProduct' do
      let(:product) { products.detect { |product| product.type == 'SimpleProduct' } }
      let(:types)   { %w(string float boolean text) }

      it 'model should have loaded all associations' do
        types.each do |type|
          product.association(HydraAttribute.config.association(type)).should be_loaded
        end
      end
    end

    describe 'GroupProduct' do
      let(:product) { products.find { |product| product.type == 'GroupProduct' } }
      let(:types)   { %w(string float boolean integer) }

      it 'model should have loaded all associations' do
        types.each do |type|
          product.association(HydraAttribute.config.association(type)).should be_loaded
        end
      end
    end
  end

  describe 'get list of hydra attribute names' do
    describe 'Product' do
      let(:attributes) { [:name, :code, :price, :active, :description, :title, :total] }
      let(:objects)    { [Product, Product.new] }

      it 'should return all attributes' do
        objects.each { |object| object.hydra_attribute_names.should =~ attributes }
      end
    end

    describe 'SimpleProduct' do
      let(:attributes) { [:name, :code, :price, :active, :description] }
      let(:objects)    { [SimpleProduct, SimpleProduct.new] }

      it 'should return own attributes' do
        objects.each { |object| object.hydra_attribute_names.should =~ attributes }
      end
    end

    describe 'GroupProduct' do
      let(:attributes) { [:name, :price, :active, :title, :total] }
      let(:objects)    { [GroupProduct, GroupProduct.new] }

      it 'should return own attributes' do
        objects.each { |object| object.hydra_attribute_names.should =~ attributes }
      end
    end
  end

  describe 'get list of hydra attribute types' do
    describe 'Product' do
      let(:types)   { [:string, :float, :boolean, :text, :integer] }
      let(:objects) { [Product, Product.new] }

      it 'should return all types' do
        objects.each { |object| object.hydra_attribute_types.should =~ types }
      end
    end

    describe 'SimpleProduct' do
      let(:types)   { [:string, :float, :boolean, :text] }
      let(:objects) { [SimpleProduct, SimpleProduct.new] }

      it 'should return own types' do
        objects.each { |object| object.hydra_attribute_types.should =~ types }
      end
    end

    describe 'GroupProduct' do
      let(:types)   { [:string, :float, :boolean, :integer] }
      let(:objects) { [GroupProduct, GroupProduct.new] }

      it 'should return own types' do
        objects.each { |object| object.hydra_attribute_types.should =~ types }
      end
    end
  end

  describe 'overwrite attributes' do
    let(:klass) do
      klass = Class.new(Product)
      klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
        hydra_attributes { |hydra| hydra.string :name }
      EOS
      klass
    end
    let(:model) { klass.new(name: 'hydra') }

    describe 'getter' do
      before do
        klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
          def name; 'test ' + super end
        EOS
      end

      it 'should overwrite attribute' do
        model.name.should == 'test hydra'
      end
    end

    describe 'setter' do
      before do
        klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
          def name=(value) super("\#{value} test") end
        EOS
      end

      it 'should overwrite attribute' do
        model.name = 'hydra'
        model.name.should == 'hydra test'
      end
    end

    describe 'question' do
      before do
        klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
          def name?; super ? 'true' : 'false' end
        EOS
      end

      it 'should overwrite attribute' do
        model.name = ''
        model.name?.should == 'false'
        model.name = '1'
        model.name?.should == 'true'
      end
    end
  end
end