module HydraAttribute
  module ActiveRecord
    module Relation
      module QueryMethods
        extend ActiveSupport::Concern

        MULTI_VALUE_METHODS = [:hydra_joins_aliases, :hydra_select_values]

        included do
          attr_writer *MULTI_VALUE_METHODS

          MULTI_VALUE_METHODS.each do |value|
            class_eval <<-EOS, __FILE__, __LINE__ + 1
              def #{value}; @#{value} ||= [] end
            EOS
          end

          alias_method_chain :where, :hydra_attribute
        end

        def where_with_hydra_attribute(opts, *rest)
          return self if opts.blank?

          if opts.is_a?(Hash)
            opts.inject(self) do |relation, (name, value)|
              if klass.hydra_attribute_names.include?(name.to_s)
                relation, name = relation.clone, name.to_s
                relation.hydra_joins_aliases << hydra_helper.ref_alias(name, value)
                relation.joins_values += hydra_helper.build_joins(name, value)
                relation.where_values += build_where(hydra_helper.where_options(name, value))
                relation
              else
                relation.where_without_hydra_attribute(name => value)
              end
            end
          else
            where_without_hydra_attribute(opts, *rest)
          end
        end

        def build_arel
          @group_values = hydra_helper.quote_columns(@group_values.uniq.reject(&:blank?))
          @order_values = hydra_helper.quote_columns(@order_values.uniq.reject(&:blank?))

          # @COMPATIBILITY with 3.1.x active_record 3.1 uses the separate @reorder_value instance
          if instance_variable_defined?(:@reorder_value) and instance_variable_get(:@reorder_value).present?
            @reorder_value = hydra_helper.quote_columns(@reorder_value.uniq.reject(&:blank?))
          end

          # detect hydra attributes from select list
          @hydra_select_values, @select_values = @select_values.partition { |value| klass.hydra_attribute_names.include?(value.to_s) }
          @hydra_select_values.map!(&:to_s)
          @select_values.map!{ |value| hydra_helper.prepend_table_name(value) }

          # attributes "id" and "hydra_set_id" are important for hydra_attribute gem
          if @hydra_select_values.any? or @select_values.any?
            @select_values << hydra_helper.prepend_table_name(klass.primary_key)
            @select_values << hydra_helper.prepend_table_name('hydra_set_id')
          end

          super
        end

        class Helper
          attr_reader :relation, :klass, :connection

          def initialize(relation)
            @relation, @klass, @connection = relation, relation.klass, relation.connection
          end

          def attr_eq_column?(attr, column)
            attr, column = attr.to_s, column.to_s
            [
              column,
              "#{klass.table_name}.#{column}",
              "#{klass.table_name}.#{connection.quote_column_name(column)}",
              "#{klass.quoted_table_name}.#{column}",
              "#{klass.quoted_table_name}.#{connection.quote_column_name(column)}"
            ].include?(attr)
          end

          def prepend_table_name(column, table = klass.table_name)
            case column
            when String, Symbol
              copy = column.to_s.strip
              if copy =~ /^\w+$/
                connection.quote_table_name(table) + '.' + connection.quote_column_name(copy)
              else
                column
              end
            else
              column
            end
          end

          def build_joins(name, value)
            conn         = klass.connection
            quoted_alias = conn.quote_table_name(ref_alias(name, value))

            [[
              "#{join_type(value)} JOIN",
              conn.quote_table_name(ref_table(name)),
              'AS',
              quoted_alias,
              'ON',
              "#{klass.quoted_table_name}.#{klass.quoted_primary_key}",
              '=',
              "#{quoted_alias}.#{conn.quote_column_name(:entity_id)}",
              'AND',
              "#{quoted_alias}.#{conn.quote_column_name(:hydra_attribute_id)}",
              '=',
              hydra_attribute_id(name)
            ].join(' ')]
          end

          def where_options(name, value)
            {ref_alias(name, value) => {value: value}}
          end

          def ref_class(name)
            type = klass.hydra_attribute(name).backend_type
            AssociationBuilder.class_name(klass, type).constantize
          end

          def ref_table(name)
            ref_class(name).table_name
          end

          def ref_alias(name, value)
            ref_table(name) + '_' + join_type(value).downcase + '_' + name
          end

          def join_type(value)
            value.nil? ? 'LEFT' : 'INNER'
          end

          def hydra_attribute_id(name)
            klass.hydra_attribute(name).id
          end

          def quote_columns(columns)
            columns.map do |column|
              column = column.respond_to?(:to_sql) ? column.to_sql : column.to_s
              if klass.hydra_attribute_names.include?(column)
                join_alias = ref_alias(column, 'inner') # alias for inner join
                join_alias = ref_alias(column, nil) unless relation.hydra_joins_aliases.include?(join_alias) # alias for left join

                relation.joins_values += build_joins(column, nil) unless relation.hydra_joins_aliases.include?(join_alias)
                prepend_table_name('value', join_alias)
              else
                prepend_table_name(column)
              end
            end
          end
        end

        private

        def hydra_helper
          @hydra_helper ||= Helper.new(self)
        end
      end
    end
  end
end