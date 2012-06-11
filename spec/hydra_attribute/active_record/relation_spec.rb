require 'spec_helper'

describe HydraAttribute::ActiveRecord::Relation do

  let(:record_class) do
    mock(:record_class, hydra_attribute_types: [:string], hydra_attribute_names: %w(code), hydra_attributes: {'code' => :string})
  end

  let(:record) do
    mock(:record, class: record_class, association: mock(loaded?: false))
  end

  let(:loaded_record) do
    mock(:loaded_record, class: record_class, association: mock(loaded?: true))
  end

  let(:exec_method) do
    ::ActiveRecord::VERSION::STRING.start_with?('3.1.') ? :to_a : :exec_queries
  end

  let(:relation) do
    mock_relation = mock(:relation, loaded?: false, select_values: [], hydra_select_values: [])

    mock_relation.stub(exec_method).and_return(records)
    mock_relation.stub(:klass).and_return(records.first.class)
    mock_relation.stub(:where).and_return(mock_relation)
    mock_relation
  end

  let(:records) do
    [record]
  end

  before do
    relation.singleton_class.send(:include, HydraAttribute::ActiveRecord::Relation)
  end

  describe "#exec_queries" do
    describe 'parent method return one record' do
      it 'should return one record' do
        relation.send(exec_method).should have(1).record
      end
    end

    describe 'parent method returns two records' do
      describe 'association models are already loaded' do
        let(:records) { [loaded_record, loaded_record] }

        it 'should return two record' do
          relation.send(exec_method).should have(2).records
        end
      end

      describe 'association models are not yet loaded' do
        let(:records) { [record, record] }

        before do
          ::ActiveRecord::Associations::Preloader.should_receive(:new).with(records, :hydra_string_attributes).and_return(mock(run: records))
        end

        it 'should return two record' do
          relation.send(exec_method).should have(2).records
        end
      end
    end
  end
end