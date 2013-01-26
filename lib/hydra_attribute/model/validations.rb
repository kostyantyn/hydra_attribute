module HydraAttribute
  module Model
    module Validations
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      class UniqueValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          table = record.class.arel_table
          arel  = record.class.select_manager

          where = table[attribute].lower.eq(table.lower(value.to_s))

          if options[:scope]
            where = Array(options[:scope]).inject(where) do |query, field|
              query.and(table[field].lower.eq(table.lower(record.send(field).to_s)))
            end
          end

          where = where.and(table[:id].not_eq(record.id)) if record.persisted?
          arel.where(where).project(table[:id])

          if record.class.connection.select_value(arel).present?
            record.errors.add(attribute, :taken, value: value)
          end
        end
      end
    end
  end
end