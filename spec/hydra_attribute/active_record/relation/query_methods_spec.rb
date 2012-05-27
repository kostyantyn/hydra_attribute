require 'spec_helper'

describe HydraAttribute::ActiveRecord::Relation::QueryMethods do
  let(:relation_class) do
    mock(
      :hydra_attributes      => {code: :string},
      :hydra_attribute_names => [:code],
      :hydra_attribute_types => [:string]
    )
  end

  let(:relation) { mock(klass: relation_class, where: nil) }

  before do
    relation.singleton_class.send :include, HydraAttribute::ActiveRecord::Relation::QueryMethods
  end

  describe '#where' do
    let(:relation) do
      mock_relation = mock(klass: relation_class)
      mock_relation.stub(:where_values)              { @where_values ||= []          }
      mock_relation.stub(:where_values=)             { |value| @where_values = value }
      mock_relation.stub(:joins_values)              { @joins_values ||= []          }
      mock_relation.stub(:joins_values=)             { |value| @joins_values = value }
      mock_relation.stub(:build_hydra_joins_values)  { |name, value| ["join-#{name}-#{value}"]  }
      mock_relation.stub(:build_hydra_where_options) { |name, value| ["where-#{name}-#{value}"] }
      mock_relation.stub(:build_where)               { |value| value }

      mock_relation.stub(:where) do |opts, *rest|
        relation = mock_relation.clone
        relation.where_values += ["opts: #{opts.inspect} - rest: #{rest.inspect}"]
        relation
      end

      mock_relation
    end

    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after do
      HydraAttribute.send :remove_const, :StringAttribute
    end

    describe 'first param is Hash' do
      let(:params) { {title: 1} }

      describe 'hash has not hydra attribute' do
        it 'should call rails native "where" method' do
          relation.where(params).where_values.join.should == %q(opts: {:title=>1} - rest: [])
        end
      end

      describe 'hash has hydra attribute' do
        let(:params) { {title: 1, code: 2, name: 3} }

        it 'should call both native and overwritten "where" method' do
          joins = 'join-code-2'
          where = %q(opts: {:title=>1} - rest: [])
          where += ' where-code-2 '
          where += %q(opts: {:name=>3} - rest: [])

          copy_relation = relation.where(params)
          copy_relation.where_values.join(' ').should == where
          copy_relation.joins_values.join(' ').should == joins
        end
      end
    end

    describe 'first param is not Hash' do
      let(:params) { 'name = 1' }

      it 'should call rails native "where" method' do
        relation.where(params).where_values.join.should == %q(opts: "name = 1" - rest: [])
      end
    end
  end

  describe '#order' do
    it 'should order'
  end

  describe '#reorder' do
    it 'should reorder'
  end

  describe '#build_arel' do
    it 'should build arel'
  end

  describe '#build_hydra_joins_values' do
    let(:connection) do
      conn = mock
      conn.stub(:quote_column_name) { |column| column.to_s        }
      conn.stub(:quote)             { |value| %Q("#{value.to_s}") }
      conn.stub(:quote_table_name)  { |table| table.to_s          }
      conn
    end

    let(:relation_class) do
      mock(
        :connection         => connection,
        :base_class         => mock(name: 'BaseClass'),
        :quoted_primary_key => 'id',
        :quoted_table_name  => 'hydra_string_attributes'
      )
    end

    let(:relation) do
      mock_relation = mock(klass: relation_class)
      mock_relation.stub(where: mock_relation)
      mock_relation.stub(:hydra_ref_alias) { |name, value| "#{name}_#{value}" }
      mock_relation.stub(:hydra_ref_table) { |name| "table_#{name}"           }
      mock_relation
    end

    describe 'value is nil' do
      let(:value) { nil }
      let(:sql)   { 'LEFT JOIN table_name AS name_ ON hydra_string_attributes.id = name_.entity_id AND name_.entity_type = "BaseClass" AND name_.name = "name"' }

      it 'should return array with one SQL query element' do
        relation.send(:build_hydra_joins_values, :name, value).should == [sql]
      end
    end

    describe 'value is not nil' do
      let(:value) { 'value' }
      let(:sql)   { 'INNER JOIN table_name AS name_value ON hydra_string_attributes.id = name_value.entity_id AND name_value.entity_type = "BaseClass" AND name_value.name = "name"' }

      it 'should return array with one SQL query element' do
        relation.send(:build_hydra_joins_values, :name, value).should == [sql]
      end
    end
  end

  describe '#build_hydra_where_options' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    it 'should create where options with table namespace' do
      relation.send(:build_hydra_where_options, :code, 'abc').should == {hydra_string_attributes_inner_code: { value: 'abc' }}
    end
  end

  describe '#hydra_ref_class' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    it 'should return class by attribute name' do
      relation.send(:hydra_ref_class, :code).should == HydraAttribute::StringAttribute
    end
  end

  describe '#hydra_ref_table' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    it 'should return table name' do
      relation.send(:hydra_ref_table, :code).should == 'hydra_string_attributes'
    end
  end

  describe '#hydra_ref_alias' do
    before do
      module HydraAttribute
        class StringAttribute
          def self.table_name
            'hydra_string_attributes'
          end
        end
      end
    end

    after { HydraAttribute.send :remove_const, :StringAttribute }

    describe 'value is nil' do
      let(:value) { nil }

      it 'should return generated alias name' do
        relation.send(:hydra_ref_alias, :code, value).should == 'hydra_string_attributes_left_code'
      end
    end

    describe 'value is not nil' do
      let(:value) { '' }

      it 'should return generated alias name' do
        relation.send(:hydra_ref_alias, :code, value).should == 'hydra_string_attributes_inner_code'
      end
    end
  end

  describe '#hydra_join_type' do
    describe 'value is nil' do
      let(:value) { nil }

      it 'should return "LEFT"' do
        relation.send(:hydra_join_type, value).should == 'LEFT'
      end
    end

    describe 'value is not nil' do
      let(:value) { '' }

      it 'should return "INNER"' do
        relation.send(:hydra_join_type, value).should == 'INNER'
      end
    end
  end
end