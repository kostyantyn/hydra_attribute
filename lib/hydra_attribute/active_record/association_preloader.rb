module HydraAttribute
  module ActiveRecord
    class AssociationPreloader
      attr_reader :relation, :records

      def initialize(relation, records = [])
        @relation = relation
        @records  = records
        prepared_records # lock attributes
      end

      def self.run(relation, records)
        new(relation, records).run
      end

      def run
        return if records.blank?

        prepared_records.keys.each_slice(in_clause_length || prepared_records.keys.length) do |entity_ids|
          grouped_attribute_ids.each do |backend_type, hydra_attribute_ids|
            next if hydra_attribute_ids.blank?

            hydra_attribute_ids.each_slice(in_clause_length || hydra_attribute_ids.length) do |attribute_ids|
              value_class(backend_type).select(%w(id entity_id hydra_attribute_id value)).where(entity_id: entity_ids, hydra_attribute_id: attribute_ids).each do |model|
                assoc = association_builder.association_name(backend_type)
                prepared_records[model.entity_id].association(assoc).target.push(model)
              end
            end
          end
        end
      end

      private

      def prepared_records
        limit = attribute_limit?
        @prepared_records ||= records.each_with_object({}) do |record, hash|
          grouped_attribute_ids.each do |backend_type, hydra_attribute_ids|
            association = record.association(association_builder.association_name(backend_type))
            limit ? association.lock!(hydra_attribute_ids) : association.loaded!
          end
          hash[record.id] = record
        end
      end

      def grouped_attribute_ids
        @grouped_attribute_ids ||= if attribute_limit?
          map = klass.hydra_attribute_backend_types.each_with_object({}) { |backend_type, hash| hash[backend_type] = [] }
          relation.hydra_select_values.each_with_object(map) do |name, grouped_ids|
            hydra_attribute = klass.hydra_attribute(name)
            grouped_ids[hydra_attribute.backend_type] << hydra_attribute.id
          end
        else
          klass.hydra_attribute_ids_by_backend_type
        end
      end

      def attribute_limit?
        relation.select_values.any? or relation.hydra_select_values.any?
      end

      def value_class(backend_type)
        instance_variable_get(:"@#{backend_type}_class") || instance_variable_set(:"@#{backend_type}_class", association_builder.class_name(klass, backend_type).constantize)
      end

      def association_builder
        AssociationBuilder
      end

      def connection
        relation.connection
      end

      def klass
        relation.klass
      end

      def in_clause_length
        connection.in_clause_length
      end
    end
  end
end