require 'spec_helper'

describe HydraAttribute::ActiveRecord::Relation::QueryMethods do
  let(:relation_class) do
    mock(
      :hydra_attributes      => {'code' => :string},
      :hydra_attribute_names => ['code'],
      :hydra_attribute_types => [:string]
    )
  end

  let(:relation) { mock(klass: relation_class, where: nil) }

  before do
    relation.singleton_class.send :include, ::ActiveRecord::QueryMethods
    relation.singleton_class.send :include, HydraAttribute::ActiveRecord::Relation::QueryMethods
  end

  describe '#where' do
    let(:relation) do
      mock_relation = mock(klass: relation_class)
      mock_relation.instance_variable_set(:@where_values, [])
      mock_relation.instance_variable_set(:@joins_values, [])
      mock_relation.stub(:build_hydra_joins_values)  { |name, value| ["join-#{name}-#{value}"]  }
      mock_relation.stub(:build_hydra_where_options) { |name, value| ["where-#{name}-#{value}"] }
      mock_relation.stub(:build_where)               { |value, *rest| ["#{value} #{rest}"] }
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
      let(:params) { {'title' => 1} }

      describe 'hash has not hydra attribute' do
        it 'should call rails native "where" method' do
          object = relation.where(params)
          object.where_values.should        == ['{"title"=>1} [[]]']
          object.joins_values.should        == []
          object.hydra_joins_aliases.should == []
        end
      end

      describe 'hash has hydra attribute' do
        let(:params) { {'title' => 1, 'code' => 2, 'name' => 3} }

        it 'should call both native and overwritten "where" method' do
          copy_relation = relation.where(params)
          copy_relation.where_values.should        == ['{"title"=>1} [[]]', 'where-code-2 []', '{"name"=>3} [[]]']
          copy_relation.joins_values.should        == ['join-code-2']
          copy_relation.hydra_joins_aliases.should == ['hydra_string_attributes_inner_code']
        end
      end
    end

    describe 'first param is not Hash' do
      let(:params) { 'name = 1' }

      it 'should call rails native "where" method' do
        copy_relation = relation.where(params)
        copy_relation.where_values.should        == ['name = 1 [[]]']
        copy_relation.joins_values.should        == []
        copy_relation.hydra_joins_aliases.should == []
      end
    end
  end

  describe '#build_arel' do
    let(:arel) { mock.as_null_object }

    let(:relation) do
      mock_relation = mock(klass: relation_class, where: nil, build_select: nil)
      mock_relation.stub_chain(:table, :from).and_return(arel)
      mock_relation.instance_variable_set(:@joins_values, [])
      mock_relation.instance_variable_set(:@order_values, [])
      mock_relation.instance_variable_set(:@where_values, [])
      mock_relation.instance_variable_set(:@having_values, [])
      mock_relation.instance_variable_set(:@group_values, [])
      mock_relation.instance_variable_set(:@select_values, [])
      mock_relation
    end

    it 'should update @order_values before generate the arel object' do
      relation.stub(build_order_values_for_arel: %w(build_order))
      relation.build_arel.should == arel
      relation.instance_variable_get(:@order_values).should == %w(build_order)
    end
  end

  describe '#build_order_values_for_arel' do
    let(:connection) do
      conn = mock
      conn.stub(:quote_column_name) { |column| column.to_s        }
      conn.stub(:quote)             { |value| %Q("#{value.to_s}") }
      conn.stub(:quote_table_name)  { |table| table.to_s          }
      conn
    end

    let(:relation_class) do
      mock(connection: connection, quoted_table_name: 'product', hydra_attribute_names: %w(code title price))
    end

    let(:relation) do
      mock_relation = mock(klass: relation_class, connection: connection)
      mock_relation.stub(where: mock_relation)
      mock_relation.stub(:hydra_ref_alias)          { |name, value| "#{name}_#{value}"        }
      mock_relation.stub(:build_hydra_joins_values) { |name, value| ["#{name}_#{value}_join"] }
      mock_relation.instance_variable_set(:@joins_values, [])
      mock_relation.instance_variable_set(:@hydra_joins_aliases, %w(code_inner title_))
      mock_relation
    end

    describe 'collection has not hydra attributes' do
      it 'should return the same collection' do
        relation.send(:build_order_values_for_arel, %w(name zone)).should == %w(product.name product.zone)
        relation.joins_values.should == []
      end
    end

    describe 'collection has hydra attributes' do
      it 'should change hydra attributes and join hydra tables' do
        relation.send(:build_order_values_for_arel, %w(name code title price)).should == %w(product.name code_inner.value title_.value price_.value)
        relation.joins_values.should == %w(price__join)
      end
    end
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
      relation.send(:build_hydra_where_options, 'code', 'abc').should == {'hydra_string_attributes_inner_code' => { value: 'abc' }}
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
      relation.send(:hydra_ref_class, 'code').should == HydraAttribute::StringAttribute
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
      relation.send(:hydra_ref_table, 'code').should == 'hydra_string_attributes'
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
        relation.send(:hydra_ref_alias, 'code', value).should == 'hydra_string_attributes_left_code'
      end
    end

    describe 'value is not nil' do
      let(:value) { '' }

      it 'should return generated alias name' do
        relation.send(:hydra_ref_alias, 'code', value).should == 'hydra_string_attributes_inner_code'
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

describe HydraAttribute::ActiveRecord::Relation::QueryMethods::Helper do
  let(:relation_class) do
    mock(table_name: 'entities', quoted_table_name: '"entities"')
  end

  let(:connection) do
    mock_connection = mock
    mock_connection.stub(:quote_column_name) { |column| %Q("#{column}") }
    mock_connection
  end

  let(:relation) do
    mock(klass: relation_class, connection: connection)
  end

  let(:helper) do
    HydraAttribute::ActiveRecord::Relation::QueryMethods::Helper.new(relation)
  end

  describe '#prepend_table_name' do
    describe 'param is Symbol' do
      it 'should prepend table name and quote param' do
        helper.prepend_table_name(:column).should == '"entities"."column"'
      end
    end

    describe 'param is String' do
      describe 'params is a word character (letter, number, underscore)' do
        it 'should prepend table name and quote param' do
          helper.prepend_table_name('abc').should == '"entities"."abc"'
          helper.prepend_table_name('a_c').should == '"entities"."a_c"'
          helper.prepend_table_name('a1c').should == '"entities"."a1c"'
          helper.prepend_table_name(' a ').should == '"entities"."a"'
        end
      end

      describe 'params is not a word character (letter, number, underscore)' do
        it 'should return current string' do
          helper.prepend_table_name('a c').should == 'a c'
          helper.prepend_table_name('a-c').should == 'a-c'
          helper.prepend_table_name('(a)').should == '(a)'
          helper.prepend_table_name('.').should   == '.'
        end
      end
    end
  end
end