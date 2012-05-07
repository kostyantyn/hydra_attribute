require 'spec_helper'

describe HydraAttribute::ActiveRecord::Relation do
  def record_class(loaded_associations = false)
    Class.new do
      define_singleton_method :base_class do
        @base_class ||= Class.new do
          define_singleton_method :hydra_attribute_types do
            [:string]
          end
        end
      end

      define_singleton_method :reflect_on_association do |_|
        true
      end

      define_method :association do |_|
        Class.new do
          define_singleton_method :loaded? do
            loaded_associations
          end
        end
      end
    end
  end

  def relation_function(records)
    Module.new do
      define_method HydraAttribute.config.relation_execute_method do
        records
      end
    end
  end

  describe "##{HydraAttribute.config.relation_execute_method}" do
    let(:ancestor) { relation_function(records) }
    let(:klass)    { Class.new.extend(ancestor) }

    describe 'parent method return one record' do
      let(:records) { [record_class.new] }

      it 'should return one record' do
        klass.extend(HydraAttribute::ActiveRecord::Relation).send(HydraAttribute.config.relation_execute_method).should have(1).record
      end
    end

    describe 'parent method returns two records' do
      let(:records) { [record_class(loaded_associations).new, record_class(loaded_associations).new] }

      describe 'association models are already loaded' do
        let(:loaded_associations) { true }

        it 'should return two record' do
          klass.extend(HydraAttribute::ActiveRecord::Relation).send(HydraAttribute.config.relation_execute_method).should have(2).records
        end
      end

      describe 'association models are not yet loaded' do
        let(:loaded_associations) { false }

        before do
          ::ActiveRecord::Associations::Preloader.should_receive(:new).with(records, :hydra_string_attributes).and_return(mock(run: records))
        end

        it 'should return two record' do
          klass.extend(HydraAttribute::ActiveRecord::Relation).send(HydraAttribute.config.relation_execute_method).should have(2).records
        end
      end
    end
  end
end