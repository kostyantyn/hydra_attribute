require 'spec_helper'

describe HydraAttribute::Attribute do
  let(:klass)     { Class.new }
  let(:attribute) { HydraAttribute::Attribute.new(klass, :name, :string) }

  describe '#build' do
    it 'should call required methods' do
      attribute.should_receive(:define_attribute_methods)
      attribute.should_receive(:save_attribute)
      attribute.build
    end
  end

  describe '#define_attribute_methods' do
    before { attribute.send(:define_attribute_methods) }

    it 'should respond to #name' do
      klass.new.should respond_to(:name)
    end

    it 'should respond to #name=' do
      klass.new.should respond_to(:name=)
    end

    it 'should respond to #name?' do
      klass.new.should respond_to(:name?)
    end

    it 'should define all methods in module' do
      [:name, :name=, :name?].each do |method|
        klass.new.method(method).owner.class.should == Module
      end
    end
  end

  describe '#store_attribute' do
    before do
      attribute.instance_variable_set(:@name, :name)
      attribute.instance_variable_set(:@type, :type)
      klass.instance_variable_set(:@hydra_attributes, {})
    end

    it 'should save attribute name and type in @hydra_attributes' do
      attribute.send(:save_attribute)
      klass.instance_variable_get(:@hydra_attributes)[:name].should == :type
    end
  end
end