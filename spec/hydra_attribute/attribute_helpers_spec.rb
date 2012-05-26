require 'spec_helper'

describe HydraAttribute::AttributeHelpers do
  let(:klass) { Class.new { include HydraAttribute::AttributeHelpers } }

  describe '.inherited' do
    it 'should clone @hydra_attributes to base class' do
      klass.instance_variable_set(:@hydra_attributes, {a: 1, b: 2})
      sub_class = Class.new(klass)
      sub_class.instance_variable_get(:@hydra_attributes).should == {a: 1, b: 2}
      sub_class.instance_variable_get(:@hydra_attributes).should_not equal(klass.instance_variable_get(:@hydra_attributes))
    end
  end

  describe '.hydra_attributes' do
    it 'should return hash of attributes' do
      klass.hydra_attributes.should == {}
    end

    it 'should return cloned hash' do
      klass.hydra_attributes.should_not equal(klass.hydra_attributes)
    end
  end

  describe '.hydra_attribute_names' do
    it 'should return hash keys' do
      klass.instance_variable_set(:@hydra_attributes, {a: 1, b: 2})
      klass.hydra_attribute_names.should == [:a, :b]
    end
  end

  describe '.hydra_attribute_types' do
    it 'should return hash values' do
      klass.instance_variable_set(:@hydra_attributes, {a: 1, b: 2})
      klass.hydra_attribute_types.should == [1, 2]
    end
  end

  describe '#hydra_attribute_model' do
    let(:code_model)  { mock(name: :code) }
    let(:title_model) { mock(name: :title) }
    let(:collection)  { [code_model, title_model] }

    before do
      HydraAttribute.config.should_receive(:association).with(:string).and_return(:string_association)
      klass.any_instance.should_receive(:string_association).and_return(collection)
    end

    describe 'type collection has built model' do
      let(:name) { :code }

      it 'should return model' do
        klass.new.hydra_attribute_model(name, :string).should == code_model
      end
    end

    describe 'type collection has not built model' do
      let(:name)  { :price }
      let(:built) { mock(:built) }

      before do
        collection.should_receive(:build).with(name: :price).and_return(built)
      end

      it 'should build model' do
        klass.new.hydra_attribute_model(name, :string).should == built
      end
    end
  end
end