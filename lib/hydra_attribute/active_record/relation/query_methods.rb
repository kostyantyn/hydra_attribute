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
              if klass.hydra_attribute_names.include?(name)
                relation = relation.clone
                relation.hydra_joins_aliases << hydra_ref_alias(name, value)
                relation.joins_values += build_hydra_joins_values(name, value)
                relation.where_values += build_where(build_hydra_where_options(name, value))
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
          @order_values = build_order_values_for_arel(@order_values)

          if instance_variable_defined?(:@reorder_value) and instance_variable_get(:@reorder_value).present? # for compatibility with 3.1.x
            @reorder_value = build_order_values_for_arel(@reorder_value)
          end

          @hydra_select_values = @select_values & klass.hydra_attribute_names
          @select_values       = (@select_values - klass.hydra_attribute_names).map { |column| hydra_attr_helper.prepend_table_name(column) }

          # force add ID for preloading hydra attributes
          if @hydra_select_values.any?
            if @select_values.none? { |v| hydra_attr_helper.attr_eq_column?(v, klass.primary_key) }
              @select_values << hydra_attr_helper.prepend_table_name(klass.primary_key)
              @id_for_hydra_attributes = true
            end
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
            attr == column || attr.end_with?(".#{column}") || attr.end_with?(".#{connection.quote_column_name(column)}")
          end

          def prepend_table_name(column)
            case column
            when Symbol, String
              if column.to_s.include?('.') or column.to_s.include?(')')
                column
              else
                klass.quoted_table_name + '.' + connection.quote_column_name(column.to_s)
              end
            else
              column
            end
          end
        end

        private

        def hydra_attr_helper
          @hydra_attr_helper ||= Helper.new(self)
        end

        def build_order_values_for_arel(collection)
          collection.map do |attribute|
            if klass.hydra_attribute_names.include?(attribute)
              join_alias = hydra_ref_alias(attribute, 'inner') # alias for inner join
              join_alias = hydra_ref_alias(attribute, nil) unless hydra_joins_aliases.include?(join_alias) # alias for left join

              @joins_values += build_hydra_joins_values(attribute, nil) unless hydra_joins_aliases.include?(join_alias)
              klass.connection.quote_table_name(join_alias) + '.' + klass.connection.quote_column_name('value')
            else
              hydra_attr_helper.prepend_table_name(attribute)
            end
          end
        end

        def build_hydra_joins_values(name, value)
          ref_alias        = hydra_ref_alias(name, value)
          conn             = klass.connection
          quoted_ref_alias = conn.quote_table_name(ref_alias)

          [[
            "#{hydra_join_type(value)} JOIN",
            conn.quote_table_name(hydra_ref_table(name)),
            'AS',
            quoted_ref_alias,
            'ON',
            "#{klass.quoted_table_name}.#{klass.quoted_primary_key}",
            '=',
            "#{quoted_ref_alias}.#{conn.quote_column_name(:entity_id)}",
            'AND',
            "#{quoted_ref_alias}.#{conn.quote_column_name(:entity_type)}",
            '=',
            conn.quote(klass.base_class.name),
            'AND',
            "#{quoted_ref_alias}.#{conn.quote_column_name(:name)}",
            '=',
            conn.quote(name)
          ].join(' ')]
        end

        def build_hydra_where_options(name, value)
          {hydra_ref_alias(name, value).to_sym => {value: value}}
        end

        def hydra_ref_class(name)
          type = klass.hydra_attributes[name]
          HydraAttribute.config.associated_model_name(type).constantize
        end

        def hydra_ref_table(name)
          hydra_ref_class(name).table_name
        end

        def hydra_ref_alias(name, value)
          hydra_ref_table(name) + '_' + hydra_join_type(value).downcase + '_' + name.to_s
        end

        def hydra_join_type(value)
          value.nil? ? 'LEFT' : 'INNER'
        end
      end
    end
  end
end