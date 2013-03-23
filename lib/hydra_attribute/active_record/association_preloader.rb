module HydraAttribute
  module ActiveRecord
    class AssociationPreloader
      attr_reader :relation, :records

      def initialize(relation, records = [])
        @relation = relation
        @records  = records
      end

      def self.run(relation, records)
        new(relation, records).run
      end

      def run
        return if records.blank?

        prepared_records.keys.each_slice(in_clause_length || records.length) do |entity_ids|
          grouped_hydra_attribute_ids.each do |backend_type, hydra_attribute_ids|
            next if hydra_attribute_ids.blank?

            hydra_attribute_ids.each_slice(in_clause_length || hydra_attribute_ids.length) do |attribute_ids|
              ::ActiveRecord::Base.connection.select_all("SELECT id, entity_id, hydra_attribute_id, value FROM hydra_#{backend_type}_#{klass.table_name} WHERE entity_id IN (#{entity_ids.join(', ')}) AND hydra_attribute_id IN (#{attribute_ids.join(', ')})").each do |attributes|
                attributes.symbolize_keys!
                attributes[:id]                 = attributes[:id].to_i                 # for PostgreSQL driver
                attributes[:entity_id]          = attributes[:entity_id].to_i          # for PostgreSQL driver
                attributes[:hydra_attribute_id] = attributes[:hydra_attribute_id].to_i # for PostgreSQL driver
                prepared_records[attributes[:entity_id]].hydra_attribute_association.set_hydra_value(attributes.symbolize_keys)
              end
            end
          end
        end
      end

      private
        def prepared_records
          @prepared_records ||= records.each_with_object({}) do |record, hash|
            hash[record.id] = record
          end
        end

        def grouped_hydra_attribute_ids
          @grouped_hydra_attribute_ids ||= begin
            hydra_attributes = ::HydraAttribute::HydraAttribute.all_by_entity_type(klass.model_name)
            if attribute_limit?
              map = hydra_attributes.map(&:backend_type).each_with_object({}) { |backend_type, hash| hash[backend_type] = [] }
              relation.hydra_select_values.each_with_object(map) do |name, grouped_ids|
                hydra_attribute = hydra_attributes.find { |attr| attr.name == name }
                grouped_ids[hydra_attribute.backend_type] << hydra_attribute.id
              end
            else
              hydra_attributes.each_with_object({}) do |hydra_attribute, hash|
                (hash[hydra_attribute.backend_type] ||= []) << hydra_attribute.id
              end
            end
          end
        end

        def attribute_limit?
          relation.select_values.any? or relation.hydra_select_values.any?
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