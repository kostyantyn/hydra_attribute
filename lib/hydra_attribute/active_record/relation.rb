module HydraAttribute
  module ActiveRecord
    module Relation
      extend ActiveSupport::Concern

      included do
        include QueryMethods
      end

      define_method HydraAttribute.config.relation_execute_method do
        return @records if loaded?
        records = super()
        return records if records.empty?

        limit_values = select_values.any? || hydra_select_values.any?

        if records.many?
          if limit_values
            hydra_attribute_types = hydra_select_values.map { |value| records.first.class.hydra_attributes[value] }.uniq
          else
            hydra_attribute_types = records.first.class.hydra_attribute_types
          end

          hydra_attribute_types.each do |type|
            association = HydraAttribute.config.association(type)
            unless records.first.association(association).loaded?
              ::ActiveRecord::Associations::Preloader.new(records, association).run
            end
          end
        end

        if limit_values
          records.each do |record| # force limit getter methods for hydra attributes
            record.instance_variable_set(:@hydra_attribute_names, hydra_select_values)
            record.instance_variable_get(:@attributes).delete('id') if @id_for_hydra_attributes
          end
        end

        records
      end

    end
  end
end