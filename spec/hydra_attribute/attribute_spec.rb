require 'spec_helper'

describe HydraAttribute::Attribute do
  let(:klass)     { Class.new }
  let(:attribute) { HydraAttribute::Attribute.new(klass, :name, :string) }

  describe '#build' do
    it 'should call required methods' do
      attribute.should_receive(:define_reflection_methods)
      attribute.should_receive(:save_attribute)
      attribute.should_receive(:define_attribute_methods)

      attribute.build
    end
  end

  describe '#defined_reflection?' do
    it 'should return true if class has defined @hydra_attributes' do
      klass.instance_variable_set(:@hydra_attributes, nil)
      attribute.should be_defined_reflection
    end

    it 'should return false if class has not defined @hydra_attributes' do
      attribute.should_not be_defined_reflection
    end
  end

  describe '#define_reflection_methods' do
    before { attribute.send(:define_reflection_methods) }

    it 'should define .hydra_attributes for class' do
      klass.instance_variable_get(:@hydra_attributes).should == {}
      klass.instance_variable_get(:@hydra_attributes)[:key] = :value
      klass.hydra_attributes.should == {key: :value}
    end

    it 'should define .hydra_attribute_names' do
      klass.hydra_attribute_names.should == []
      klass.instance_variable_get(:@hydra_attributes)[:key1] = :value1
      klass.instance_variable_get(:@hydra_attributes)[:key2] = :value2
      klass.instance_variable_get(:@hydra_attributes)[:key3] = :value1
      klass.hydra_attribute_names.should == [:key1, :key2, :key3]
    end

    it 'should define .hydra_attribute_types' do
      klass.hydra_attribute_names.should == []
      klass.instance_variable_get(:@hydra_attributes)[:key1] = :value1
      klass.instance_variable_get(:@hydra_attributes)[:key2] = :value2
      klass.instance_variable_get(:@hydra_attributes)[:key3] = :value1
      klass.hydra_attribute_types.should == [:value1, :value2]
    end

    describe 'should define #hydra_attribute_model' do
      let(:attr) { mock(name: :code) }

      before do
        attrs = [attr]
        klass.send :define_method, :hydra_string_attributes do
          @attrs ||= attrs
        end
      end

      describe 'association method return list of attributes' do
        it 'should return attribute model if it exists' do
          klass.new.hydra_attribute_model(:code, :string).should == attr
        end
      end

      describe 'association method return nil' do
        it 'should build attribute model' do
          klass.new.hydra_string_attributes.should_receive(:build).with(name: :title).and_return(attr)
          klass.new.hydra_attribute_model(:title, :string).should == attr
        end
      end
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