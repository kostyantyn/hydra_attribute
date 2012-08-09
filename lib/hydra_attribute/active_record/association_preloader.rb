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
        return if hydra_attribute_ids.blank?

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
        @prepared_records ||= records.each_with_object({}) do |record, hash|
          grouped_attribute_ids.each do |backend_type, ids|
            record.association(association_builder.association_name(backend_type)).lock_for_build!(ids)
          end
          hash[record.id] = record
        end
      end

      def grouped_attribute_ids
        @grouped_attribute_ids ||= begin
          map = klass.hydra_attribute_backend_types.each_with_object({}) { |type, object| object[type] = [] }
          hydra_attributes.each_with_object(map) do |hydra_attribute, mapping|
            mapping[hydra_attribute.backend_type] << hydra_attribute.id
          end
        end
      end

      def hydra_attributes
        @hydra_attributes ||= if attribute_limit?
          relation.hydra_select_values.map { |name| klass.hydra_attribute(name) }
        else
          klass.hydra_attributes
        end
      end

      def hydra_attribute_ids
        @hydra_attribute_ids ||= hydra_attributes.map(&:id)
      end

      def hydra_attribute_backend_types
        @hydra_attribute_backend_types ||= hydra_attributes.map(&:backend_type).uniq
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