module HydraAttribute
  class HydraAttribute

    # This error is raised when created +HydraAttribute::HydraAttribute+ models don't have this ID
    class UnknownHydraAttributeIdError < ArgumentError
    end

    include ::HydraAttribute::Model

    validates :entity_type,  presence: true
    validates :name,         presence: true, unique: { scope: :entity_type }
    validates :backend_type, presence: true, inclusion: { in: ::HydraAttribute::SUPPORTED_BACKEND_TYPES }

    define_cached_singleton_method :all_by_entity_type,           cache_key: :entity_type, cache_value: :self,         cache_key_cast: :to_s
    define_cached_singleton_method :ids_by_entity_type,           cache_key: :entity_type, cache_value: :id,           cache_key_cast: :to_s
    define_cached_singleton_method :names_by_entity_type,         cache_key: :entity_type, cache_value: :name,         cache_key_cast: :to_s
    define_cached_singleton_method :backend_types_by_entity_type, cache_key: :entity_type, cache_value: :backend_type, cache_key_cast: :to_s

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