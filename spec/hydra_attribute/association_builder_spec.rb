require 'spec_helper'

describe HydraAttribute::AssociationBuilder do
  def remove_association
    [::HydraAttribute, ::Object].each do |klass|
      klass.send(:remove_const, :StringValue) if klass.constants.include?(:StringValue)
    end
  end

  after(:each) { remove_association }

  let(:klass) do
    Class.new do
      @reflection = {}
      define_singleton_method :reflect_on_association do |assoc|
        @reflection[assoc]
      end
      define_singleton_method :has_many do |assoc, options|
        @reflection[assoc] = options
      end
    end
  end

  let(:type)        { :string }
  let(:association) { HydraAttribute::AssociationBuilder.new(klass, type) }

  describe '#buld' do
    it 'should call #build_associated_model and build_association' do
      association.should_receive(:create_associated_model)
      association.should_receive(:add_association_for_class)
      association.build
    end
  end

  describe '#create_associated_model' do
    describe 'use namespace for associated models' do
      it 'should create new model' do
        association.send(:create_associated_model)
        HydraAttribute.should be_const_defined(:StringValue)
      end
    end

    describe 'should not use namespace for associated models' do
      before { HydraAttribute.config.use_module_for_associated_models = false }
      after  { HydraAttribute.config.use_module_for_associated_models = true  }

      it 'should create new model' do
        association.send(:create_associated_model)
        Object.should be_const_defined(:StringValue)
      end
    end

    describe 'do not try to create twice the same class' do
      it 'should not warn "already initialized constant"' do
        association.send(:create_associated_model)
        HydraAttribute.should_not_receive(:const_set)
        association.send(:create_associated_model)
      end
    end

    describe 'set correct table name' do
      it 'should be :hydra_string_attributes' do
        association.send(:create_associated_model)
        HydraAttribute::StringValue.table_name.should == 'hydra_string_values'
      end
    end

    describe 'set correct belongs_to' do
      it 'should be polymorphic association' do
        association.send(:create_associated_model)
        reflection = HydraAttribute::StringValue.reflect_on_association(:entity)
        reflection.macro.should == :belongs_to
        reflection.options[:polymorphic].should be_true
        reflection.options[:touch].should be_true
        reflection.options[:autosave].should be_true
      end
    end
  end

  describe '#add_association_for_class' do
    it 'should add has_many association for class' do
      association.send(:add_association_for_class)
      reflection = klass.reflect_on_association(:hydra_string_values)
      reflection[:as].should  == :entity
      reflection[:class_name].should == 'HydraAttribute::StringValue'
      reflection[:autosave].should be_true
    end

    it 'should not add twice the same has_many association' do
      association.send(:add_association_for_class)
      klass.should_not_receive(:has_many)
      association.send(:add_association_for_class)
    end
  end
end