module HydraAttribute
  module ActiveRecord
    module Relation
      module QueryMethods
        extend ActiveSupport::Concern

        included do
          alias_method_chain :where, :hydra_attribute
        end

        def where_with_hydra_attribute(opts, *rest)
          return self if opts.blank?

          if opts.is_a?(Hash)
            opts.inject(self) do |relation, (name, value)|
              if klass.hydra_attribute_names.include?(name)
                relation = relation.clone
                relation.hydra_joins_values << hydra_ref_alias(name, value)
                relation.joins_values       += build_hydra_joins_values(name, value)
                relation.where_values       += build_where(build_hydra_where_options(name, value))
                relation
              else
                relation.where_without_hydra_attribute(name => value)
              end
            end
          else
            where_without_hydra_attribute(opts, *rest)
          end
        end

        def order(*args)
          relation = super(*(args.flatten - klass.hydra_attribute_names))

          if (attributes = args.flatten & klass.hydra_attribute_names).any?
            relation = clone if relation.equal?(self)
            relation.hydra_order_values += attributes
          end

          relation
        end

        def reorder(*args)
          relation = super(*args)
          relation.hydra_order_values = [] unless relation.equal?(self)
          relation
        end

        # Should lazy join appropriate hydra tables for order fields
        # because it is impossible to predict what join type should be used
        def build_arel
          hydra_order_values.each do |attribute|
            join_alias = hydra_ref_alias(attribute, 'inner') # alias for inner join
            join_alias = hydra_ref_alias(attribute, nil) unless hydra_joins_values.include?(join_alias) # alias for left join

            self.joins_values += build_hydra_joins_values(attribute, nil) unless hydra_joins_values.include?(join_alias)
            self.order_values += [klass.connection.quote_table_name(join_alias) + '.' + klass.connection.quote_column_name('value')]
          end

          super
        end

        protected

        def hydra_joins_values
          @hydra_joins_values ||= []
        end

        def hydra_order_values
          @hydra_order_values ||= []
        end

        def hydra_order_values=(value)
          @hydra_order_values = value
        end

        private

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