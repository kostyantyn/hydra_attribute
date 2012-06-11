require 'spec_helper'

describe HydraAttribute::ActiveRecord::Relation do
  def record_class(loaded_associations = false)
    Class.new do

      @hydra_attributes = {'code' => :string}
      define_singleton_method :hydra_attribute_types do
        [:string]
      end

      define_singleton_method :hydra_attribute_names do
        ['code']
      end

      define_singleton_method :hydra_attributes do
        @hydra_attributes
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
      define_method :loaded? do
        false
      end

      define_method :select_values do
        []
      end

      define_method :hydra_select_values do
        []
      end

      define_method :exec_queries do
        records
      end

      if ::ActiveRecord::VERSION::STRING.start_with?('3.1.')
        define_method :to_a do
          records
        end
      end

      define_method :klass do
        records.first.class
      end

      define_method :where do |*|
        self
      end
    end
  end

  let(:records)  { [record_class.new] }
  let(:ancestor) { relation_function(records) }
  let(:klass)    do
    object   = Class.new.send(:include, ancestor)
    instance = object.new
    instance.singleton_class.send(:include, HydraAttribute::ActiveRecord::Relation)
    instance
  end

  describe "#exec_queries" do
    let(:exec_queries) do
      if ::ActiveRecord::VERSION::STRING.start_with?('3.1.')
        :to_a
      else
        :exec_queries
      end
    end

    describe 'parent method return one record' do
      it 'should return one record' do
        klass.send(exec_queries).should have(1).record
      end
    end

    describe 'parent method returns two records' do
      let(:records) { [record_class(loaded_associations).new, record_class(loaded_associations).new] }

      describe 'association models are already loaded' do
        let(:loaded_associations) { true }

        it 'should return two record' do
          klass.send(exec_queries).should have(2).records
        end
      end

      describe 'association models are not yet loaded' do
        let(:loaded_associations) { false }

        before do
          ::ActiveRecord::Associations::Preloader.should_receive(:new).with(records, :hydra_string_attributes).and_return(mock(run: records))
        end

        it 'should return two record' do
          klass.send(exec_queries).should have(2).records
        end
      end
    end
  end
end