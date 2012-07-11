module HydraAttribute
  module ActiveRecord
    module Relation
      extend ActiveSupport::Concern

      included do
        include QueryMethods

        target = ::ActiveRecord::VERSION::STRING.starts_with?('3.1.') ? :to_a : :exec_queries
        alias_method :__old_exec_queries__, target
        alias_method target, :__exec_queries__
      end

      def __exec_queries__
        return @records if loaded?
        records = __old_exec_queries__
        return records if records.empty?

        # TODO should be a separate preloader class
        hydra_attributes = if select_values.any? or hydra_select_values.any?
          hydra_select_values.map { |attribute| klass.hydra_attribute(attribute) }
        else
          klass.hydra_attributes
        end

        preload_options = hydra_attributes.each_with_object({}) do |hydra_attribute, hash|
          hash[hydra_attribute.backend_type] ||= {conditions: {hydra_attribute_id: []}}
          hash[hydra_attribute.backend_type][:conditions][:hydra_attribute_id] << hydra_attribute.id
        end

        klass.hydra_attribute_backend_types.each do |type|
          association = AssociationBuilder.new(klass, type).association_name
          unless records.first.association(association).loaded?
            if preload_options.has_key?(type)
              ::ActiveRecord::Associations::Preloader.new(records, association, preload_options[type]).run

              records.each do |record| # preloader class should create blank attributes
                hydra_ids = record.association(association).target.map(&:id)
                preload_options[type][:conditions][:hydra_attribute_id].each do |hydra_id|
                  unless hydra_ids.include?(hydra_id)
                    record.association(association).build(hydra_attribute_id: hydra_id)
                  end
                end
              end
            else
              records.each do |record|
                record.association(association).loaded!
              end
            end
          end
        end

        records
      end
    end
  end
end