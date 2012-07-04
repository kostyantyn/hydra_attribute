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
          @group_values = build_hydra_values_for_arel(@group_values.uniq.reject(&:blank?))
          @order_values = build_hydra_values_for_arel(@order_values.uniq.reject(&:blank?))

          if instance_variable_defined?(:@reorder_value) and instance_variable_get(:@reorder_value).present? # for compatibility with 3.1.x
            @reorder_value = build_hydra_values_for_arel(@reorder_value.uniq.reject(&:blank?))
          end

          @hydra_select_values, @select_values = @select_values.partition { |value| klass.hydra_attribute_names.include?(value.to_s) }
          @hydra_select_values.map!(&:to_s)
          @select_values.map!{ |value| hydra_helper.prepend_table_name(value) }

          # force add ID for preloading hydra attributes
          if @hydra_select_values.any? && @select_values.none? { |v| hydra_helper.attr_eq_column?(v, klass.primary_key) }
            @select_values << hydra_helper.prepend_table_name(klass.primary_key)
            @id_for_hydra_attributes = true
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

          def prepend_table_name(column)
            return column unless column.is_a?(Symbol) or column.is_a?(String)

            copy = column.to_s.strip
            if copy =~ /^\w+$/
              klass.quoted_table_name + '.' + connection.quote_column_name(copy)
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
            type = klass.hydra_attribute_data(name)['backend_type']
            AssociationBuilder.new(klass, type).class_name.constantize
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
            klass.hydra_attribute_data(name)['id']
          end
        end

        private

        def hydra_helper
          @hydra_helper ||= Helper.new(self)
        end

        def build_hydra_values_for_arel(collection)
          collection.map do |attribute|
            attribute = attribute.respond_to?(:to_sql) ? attribute.to_sql : attribute.to_s
            if klass.hydra_attribute_names.include?(attribute)
              join_alias = hydra_helper.ref_alias(attribute, 'inner') # alias for inner join
              join_alias = hydra_helper.ref_alias(attribute, nil) unless hydra_joins_aliases.include?(join_alias) # alias for left join

              @joins_values += hydra_helper.build_joins(attribute, nil) unless hydra_joins_aliases.include?(join_alias)
              klass.connection.quote_table_name(join_alias) + '.' + klass.connection.quote_column_name('value')
            else
              hydra_helper.prepend_table_name(attribute)
            end
          end
        end
      end
    end
  end
end