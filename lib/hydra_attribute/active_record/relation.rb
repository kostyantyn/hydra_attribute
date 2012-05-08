module HydraAttribute
  module ActiveRecord
    module Relation
      define_method HydraAttribute.config.relation_execute_method do
        records = super()
        if records.many?
          records.first.class.base_class.hydra_attribute_types.each do |type|
            relation = HydraAttribute.config.association(type)
            record   = records.detect { |record| record.class.reflect_on_association(relation).present? }
            if record and !record.association(relation).loaded?
              ::ActiveRecord::Associations::Preloader.new(records, relation).run
            end
          end
        end
        records
      end

      def where(opts, *rest)
        return self if opts.blank?

        if opts.is_a?(Hash)
          opts.inject(self) do |relation, (name, value)|
            if klass.hydra_attribute_names.include?(name)
              relation = relation.clone
              relation.joins_values += build_hydra_joins_values(name, value)
              relation.where_values += build_where(build_hydra_where_options(name, value))
              relation
            else
              relation.where(name => value)
            end
          end
        else
          super(opts, *rest)
        end
      end

      def build_hydra_joins_values(name, value)
        ref_alias = hydra_ref_alias(name, value)

        @hydra_join_values ||= {}
        return [] if @hydra_join_values.has_key?(ref_alias)
        @hydra_join_values[ref_alias] = value

        conn             = klass.connection
        quoted_ref_alias = conn.quote_column_name(ref_alias)

        self.joins_values += [[
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
        type = klass.hydra_attribute_types.find { |type| klass.instance_variable_get(:@hydra_attributes)[type].include?(name) }
        HydraAttribute.config.associated_model_name(type).constantize
      end

      def hydra_ref_table(name)
        hydra_ref_class(name).table_name
      end

      def hydra_ref_alias(name, value)
        hydra_ref_table(name) + hydra_join_type(value) + name.to_s
      end

      def hydra_join_type(value)
        value.nil? ? 'LEFT' : 'INNER'
      end
    end
  end
end