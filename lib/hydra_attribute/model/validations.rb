module HydraAttribute
  module Model
    module Validations
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      class UniqueValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          klass = record.class
          table = record.class.arel_table
          arel  = record.class.select_manager

          where = comparison(table, attribute, value, klass.column(attribute.to_s).text?)

          if options[:scope]
            where = Array(options[:scope]).inject(where) do |query, field|
              query.and(comparison(table, field, record.send(field), klass.column(field.to_s).text?))
            end
          end

          where = where.and(table[:id].not_eq(record.id)) if record.persisted?
          arel.where(where).project(table[:id])

          if record.class.connection.select_value(arel).present?
            record.errors.add(attribute, :taken, value: value)
          end
        end

        private
          def comparison(table, field, value, insensitive = true)
            if insensitive
              table[field].lower.eq(table.lower(value))
            else
              table[field].eq(value)
            end
          end
      end
    end
  end
end
