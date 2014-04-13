module HydraAttribute
  class HydraAttribute
    VALID_NAME_FORMAT = /\A\w+\z/i

    # This error is raised when created +HydraAttribute::HydraAttribute+ models don't have this ID
    class UnknownHydraAttributeIdError < ArgumentError
    end

    include ::HydraAttribute::Model

    validates :entity_type,  presence: true
    validates :name,         presence: true,
                             unique:    { scope: :entity_type },
                             format:    { with: VALID_NAME_FORMAT },
                             exclusion: { in: :forbidden_method_names }
    validates :backend_type, presence: true, inclusion: { in: ::HydraAttribute::SUPPORTED_BACKEND_TYPES }

    define_cached_singleton_method :all_by_entity_type,           cache_key: :entity_type, cache_value: :self,         cache_key_cast: :to_s
    define_cached_singleton_method :ids_by_entity_type,           cache_key: :entity_type, cache_value: :id,           cache_key_cast: :to_s
    define_cached_singleton_method :names_by_entity_type,         cache_key: :entity_type, cache_value: :name,         cache_key_cast: :to_s
    define_cached_singleton_method :backend_types_by_entity_type, cache_key: :entity_type, cache_value: :backend_type, cache_key_cast: :to_s

    has_many :hydra_sets, through: :hydra_attribute_set, copy_attribute: :entity_type

    def forbidden_method_names
      entity_class = entity_type && entity_type.safe_constantize
      if entity_class
        forbidden_method_names =  entity_class.column_names
        forbidden_method_names += entity_class.instance_methods
        forbidden_method_names += entity_class.private_instance_methods
        forbidden_method_names.map(&:to_s).grep(VALID_NAME_FORMAT)
      else
        []
      end
    end
  end
end
