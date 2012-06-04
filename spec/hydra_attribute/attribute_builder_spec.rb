require 'spec_helper'

describe HydraAttribute::AttributeBuilder do
  let(:klass)     { Class.new }
  let(:attribute) { HydraAttribute::AttributeBuilder.new(klass, :name, :string) }

  describe '#build' do
    it 'should call required methods' do
      attribute.should_receive(:define_attribute_methods)
      attribute.should_receive(:save_attribute)
      attribute.build
    end
  end

  describe '#define_attribute_methods' do
    let(:matcher_get) do
      mock_matcher = mock
      mock_matcher.stub(:method_name) { |value| value.to_s }
      mock_matcher
    end

    let(:matcher_set) do
      mock_matcher = mock
      mock_matcher.stub(:method_name) { |value| "#{value}=" }
      mock_matcher
    end

    let(:matcher_query) do
      mock_matcher = mock
      mock_matcher.stub(:method_name) { |value| "#{value}?" }
      mock_matcher
    end

    before do
      klass.stub(attribute_method_matchers: [matcher_get, matcher_set, matcher_query])
      attribute.send(:define_attribute_methods)
    end

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