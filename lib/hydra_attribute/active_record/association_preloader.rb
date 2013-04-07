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
            next if hydra_attribute_ids.blank? # entity doesn't have any hydra attributes for the current backend type

            # set values from database
            database_entity_and_hydra_attribute_ids = {}
            hydra_attribute_ids.each_slice(in_clause_length || hydra_attribute_ids.length) do |attribute_ids|
              ::ActiveRecord::Base.connection.select_all("SELECT id, entity_id, hydra_attribute_id, value FROM hydra_#{backend_type}_#{klass.table_name} WHERE entity_id IN (#{entity_ids.join(', ')}) AND hydra_attribute_id IN (#{attribute_ids.join(', ')})").each do |attributes|
                # PostgreSQL driver doesn't convert values, it returns them as strings
                id                 = attributes['id'].to_i
                entity_id          = attributes['entity_id'].to_i
                hydra_attribute_id = attributes['hydra_attribute_id'].to_i

                assign_hydra_value_options(id: id, entity_id: entity_id, hydra_attribute_id: hydra_attribute_id, value: attributes['value'])
                (database_entity_and_hydra_attribute_ids[entity_id] ||= []) << hydra_attribute_id
              end
            end

            # set nil if attribute's value is not saved into the database
            # these values are not persisted
            entity_ids.each do |entity_id|
              missing_hydra_attribute_ids = hydra_attribute_ids - Array(database_entity_and_hydra_attribute_ids[entity_id])
              missing_hydra_attribute_ids.each do |missing_hydra_attribute_id|
                assign_hydra_value_options(entity_id: entity_id, hydra_attribute_id: missing_hydra_attribute_id, value: nil)
              end
            end
          end
        end
      end

      def assign_hydra_value_options(options = {})
        entity = prepared_records[options[:entity_id]]
        assoc  = entity.hydra_attribute_association

        if entity.hydra_set_id
          assoc.hydra_value_options = options.symbolize_keys if entity.hydra_set.has_hydra_attribute_id?(options[:hydra_attribute_id])
        else
          assoc.hydra_value_options = options.symbolize_keys
        end
      end

      private
        def prepared_records
          @prepared_records ||= records.each_with_object({}) do |record, hash|
            record.hydra_attribute_association.lock_values
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