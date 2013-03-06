module HydraAttribute
  class HydraAttribute

    # This error is raised when created +HydraAttribute::HydraAttribute+ models don't have this ID
    class UnknownHydraAttributeIdError < ArgumentError
    end

    include ::HydraAttribute::Model

    validates :entity_type,  presence: true
    validates :name,         presence: true, unique: { scope: :entity_type }
    validates :backend_type, presence: true, inclusion: { in: ::HydraAttribute::SUPPORTED_BACKEND_TYPES }

    register_nested_cache :hydra_attributes_by_entity_type
    register_nested_cache :hydra_attribute_ids_by_entity_type
    register_nested_cache :hydra_attribute_names_by_entity_type

    class << self
      # Finds all +HydraAttribute::HydraAttribute+ models by +entity_type+
      # This method is cacheable
      #
      # @params [String]
      # @return [Array<HydraAttribute::HydraAttribute>]
      def hydra_attributes_by_entity_type(entity_type)
        get_from_nested_cache_or_load_all_models(:hydra_attributes_by_entity_type, entity_type.to_s) || []
      end

      # Finds all attribute IDs by +entity_type+
      # This method is cacheable
      #
      # @param [String]
      # @return [Array<Fixnum>]
      def hydra_attribute_ids_by_entity_type(entity_type)
        get_from_nested_cache_or_load_all_models(:hydra_attribute_ids_by_entity_type, entity_type.to_s)
      end

      # Finds all attribute names by +entity_type+
      # This method is cacheable
      #
      # @param [String]
      # @return [Array<String>]
      def hydra_attribute_names_by_entity_type(entity_type)
        get_from_nested_cache_or_load_all_models(:hydra_attribute_names_by_entity_type, entity_type.to_s)
      end

      def attribute_proxy_class(entity_class)
        ::HydraAttribute.identity_map[entity_class.model_name] ||= begin
          klass = Class.new(HydraEntityAttributeProxy)
          klass.entity_class = entity_class
          klass
        end
      end

      private
        def add_to_hydra_attributes_by_entity_type_cache(hydra_attribute)
          add_value_to_nested_cache(:hydra_attributes_by_entity_type, key: hydra_attribute.entity_type, value: hydra_attribute)
        end

        def update_hydra_attributes_by_entity_type_cache(hydra_attribute)
          delete_value_from_nested_cache(:hydra_attributes_by_entity_type, key: hydra_attribute.entity_type_was, value: hydra_attribute)
          add_value_to_nested_cache(:hydra_attributes_by_entity_type, key: hydra_attribute.entity_type, value: hydra_attribute)
        end

        def delete_from_hydra_attributes_by_entity_type_cache(hydra_attribute)
          delete_value_from_nested_cache(:hydra_attributes_by_entity_type, key: hydra_attribute.entity_type, value: hydra_attribute)
        end

        def add_to_hydra_attribute_ids_by_entity_type_cache(hydra_attribute)
          add_value_to_nested_cache(:hydra_attribute_ids_by_entity_type, key: hydra_attribute.entity_type, value: hydra_attribute.id)
        end

        def delete_from_hydra_attribute_ids_by_entity_type_cache(hydra_attribute)
          delete_value_from_nested_cache(:hydra_attribute_ids_by_entity_type, key: hydra_attribute.entity_type, value: hydra_attribute.id)
        end

        def add_to_hydra_attribute_names_by_entity_type_cache(hydra_attribute)
          add_value_to_nested_cache(:hydra_attribute_names_by_entity_type, key: hydra_attribute.entity_type,value: hydra_attribute.name)
        end

        def delete_from_hydra_attribute_names_by_entity_type_cache(hydra_attribute)
          delete_value_from_nested_cache(:hydra_attribute_names_by_entity_type, key: hydra_attribute.entity_type, value: hydra_attribute.name)
        end
    end

    # Returns collection of hydra sets for this hydra attribute
    #
    # @return [Array<HydraAttribute::HydraSet>]
    def hydra_sets
      if id?
        HydraAttributeSet.hydra_sets_by_hydra_attribute_id(id)
      else
        []
      end
    end
  end
end