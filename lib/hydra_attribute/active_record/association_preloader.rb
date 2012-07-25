module HydraAttribute
  module ActiveRecord
    class AssociationPreloader
      attr_reader :relation, :records, :hashed_records

      def initialize(relation, records = [])
        @relation       = relation
        @records        = records
        @hashed_records = records.each_with_object({}) { |record, hash| hash[record.id] = record }
      end

      def self.run(relation, records)
        new(relation, records).run
      end

      def run
        grouped_values do |association, values, white_list_attribute_ids|
          association.target.concat(values)
          association.lock_for_build!(white_list_attribute_ids)
        end
      end

      private

      def grouped_values
        grouped_attribute_ids do |type, attribute_ids|
          association_name = AssociationBuilder.association_name(type)
          load_values(type, attribute_ids) do |record, values|
            yield(record.association(association_name), values, attribute_ids)
          end
        end
      end

      def load_values(type, attribute_ids)
        return records.each { |record| yield(record, []) } if attribute_ids.empty?

        attribute_ids.each_slice(in_clause_length || attribute_ids.length) do |sliced_attribute_ids|
          records.each_slice(in_clause_length || records.length) do |sliced_records|
            values = AssociationBuilder.class_name(klass, type).constantize.select([:id, :entity_id, :hydra_attribute_id, :value]).where(entity_id: sliced_records, hydra_attribute_id: sliced_attribute_ids)
            group_records_with_values(sliced_records, values).each do |record_id, grouped_values|
              yield(hashed_records[record_id], grouped_values)
            end
          end
        end
      end

      def group_records_with_values(records, values)
        hash = records.each_with_object({}) { |record, hash| hash[record.id] = [] }
        values.each { |value| hash[value.entity_id] << value }
        hash
      end

      def grouped_attribute_ids
        map     = klass.hydra_attribute_backend_types.each_with_object({}) { |type, object| object[type] = [] }
        mapping = hydra_attributes.each_with_object(map) do |hydra_attribute, mapping|
          mapping[hydra_attribute.backend_type] << hydra_attribute.id
        end
        mapping.each { |type, ids| yield(type, ids) }
      end

      def hydra_attributes
        if attribute_limit?
          relation.hydra_select_values.map { |name| klass.hydra_attribute(name) }
        else
          klass.hydra_attributes
        end
      end

      def attribute_limit?
        relation.select_values.any? or relation.hydra_select_values.any?
      end

      def klass
        relation.klass
      end

      def in_clause_length
        klass.connection.in_clause_length
      end
    end
  end
end