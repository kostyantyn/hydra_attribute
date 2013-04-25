module HydraAttribute
  class HydraAttributeSet
    include ::HydraAttribute::Model

    define_cached_singleton_method :all_by_hydra_attribute_id,           cache_key: :hydra_attribute_id, cache_value: :self,               cache_key_cast: :to_i
    define_cached_singleton_method :all_by_hydra_set_id,                 cache_key: :hydra_set_id,       cache_value: :self,               cache_key_cast: :to_i
    define_cached_singleton_method :hydra_attributes_by_hydra_set_id,    cache_key: :hydra_set_id,       cache_value: :hydra_attribute,    cache_key_cast: :to_i
    define_cached_singleton_method :hydra_sets_by_hydra_attribute_id,    cache_key: :hydra_attribute_id, cache_value: :hydra_set,          cache_key_cast: :to_i
    define_cached_singleton_method :hydra_attribute_ids_by_hydra_set_id, cache_key: :hydra_set_id,       cache_value: :hydra_attribute_id, cache_key_cast: :to_i
    define_cached_singleton_method :hydra_set_ids_by_hydra_attribute_id, cache_key: :hydra_attribute_id, cache_value: :hydra_set_id,       cache_key_cast: :to_i

    register_nested_cache :hydra_attribute_ids_by_hydra_set_id_as_hash

    observe 'HydraAttribute::HydraAttribute', after_destroy: :hydra_attribute_destroyed
    observe 'HydraAttribute::HydraSet',       after_destroy: :hydra_set_destroyed

    validates :hydra_set_id,       presence: true
    validates :hydra_attribute_id, presence: true, unique: { scope: :hydra_set_id }

    class << self
      def has_hydra_attribute_id_in_hydra_set_id?(hydra_attribute_id, hydra_set_id)
        hydra_attribute_ids = get_from_nested_cache_or_load_all_models(:hydra_attribute_ids_by_hydra_set_id_as_hash, hydra_set_id.to_i)
        hydra_attribute_ids and hydra_attribute_ids.has_key?(hydra_attribute_id.to_i)
      end

      # Remove hydra attribute from the cache
      def hydra_attribute_destroyed(hydra_attribute) #:nodoc:
        all_by_hydra_attribute_id(hydra_attribute.id).each(&:destroy)
      end

      # Remove hydra set from the cache
      def hydra_set_destroyed(hydra_set) #:nodoc:
        all_by_hydra_set_id(hydra_set.id).each(&:destroy)
      end

      private
        def add_to_hydra_attribute_ids_by_hydra_set_id_as_hash_cache(hydra_attribute_set)
          add_value_to_nested_hash_cache(:hydra_attribute_ids_by_hydra_set_id_as_hash, key: hydra_attribute_set.hydra_set_id, value: hydra_attribute_set.hydra_attribute_id)
        end

        def update_hydra_attribute_ids_by_hydra_set_id_as_hash_cache(hydra_attribute_set)
          delete_value_from_nested_hash_cache(:hydra_attribute_ids_by_hydra_set_id_as_hash, key: hydra_attribute_set.hydra_set_id_was, value: hydra_attribute_set.hydra_attribute_id_was)
          add_to_hydra_attribute_ids_by_hydra_set_id_as_hash_cache(hydra_attribute_set)
        end

        def delete_from_hydra_attribute_ids_by_hydra_set_id_as_hash_cache(hydra_attribute_set)
          delete_value_from_nested_hash_cache(:hydra_attribute_ids_by_hydra_set_id_as_hash, key: hydra_attribute_set.hydra_set_id, value: hydra_attribute_set.hydra_attribute_id)
        end
    end

    # Returns hydra attribute for this relation
    #
    # @return [HydraAttribute::HydraAttribute, NilClass]
    def hydra_attribute
      ::HydraAttribute::HydraAttribute.find(hydra_attribute_id) if hydra_attribute_id
    end
    alias_method :hydra_attribute_was, :hydra_attribute # used for cache sweepers

    # Returns hydra set for this relation
    #
    # @return [HydraAttribute::HydraSet, NilClass]
    def hydra_set
      ::HydraAttribute::HydraSet.find(hydra_set_id) if hydra_set_id
    end
    alias_method :hydra_set_was, :hydra_set # used for cache sweepers
  end
end