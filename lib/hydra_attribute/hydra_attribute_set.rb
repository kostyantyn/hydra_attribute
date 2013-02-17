module HydraAttribute
  class HydraAttributeSet
    include ::HydraAttribute::Model

    register_nested_cache :hydra_attribute_sets_by_hydra_attribute_id
    register_nested_cache :hydra_attribute_sets_by_hydra_set_id

    register_nested_cache :hydra_attributes_by_hydra_set_id
    register_nested_cache :hydra_sets_by_hydra_attribute_id

    register_nested_cache :hydra_attribute_ids_by_hydra_set_id
    register_nested_cache :hydra_attribute_ids_by_hydra_set_id_as_hash

    register_nested_cache :hydra_set_ids_by_hydra_attribute_id
    register_nested_cache :hydra_set_ids_by_hydra_attribute_id_as_hash

    observe 'HydraAttribute::HydraAttribute', after_destroy: :hydra_attribute_destroyed
    observe 'HydraAttribute::HydraSet',       after_destroy: :hydra_set_destroyed

    validates :hydra_set_id,       presence: true
    validates :hydra_attribute_id, presence: true, unique: { scope: :hydra_set_id }

    class << self
      # Finds all +HydraAttribute::HydraAttributeSet+ models which have the following +hydra_attribute_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_attribute_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id)
        get_from_nested_cache_or_load_all_models(:hydra_attribute_sets_by_hydra_attribute_id, hydra_attribute_id.to_i)
      end

      # Finds all +HydraAttribute::HydraAttributeSet+ models which have the following +hydra_set_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_set_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_attribute_sets_by_hydra_set_id(hydra_set_id)
        get_from_nested_cache_or_load_all_models(:hydra_attribute_sets_by_hydra_set_id, hydra_set_id.to_i)
      end

      # Finds all +HydraAttribute::HydraAttribute+ models for the following +hydra_set_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_set_id
      # @return [Array<HydraAttribute::HydraAttribute>]
      def hydra_attributes_by_hydra_set_id(hydra_set_id)
        get_from_nested_cache_or_load_all_models(:hydra_attributes_by_hydra_set_id, hydra_set_id.to_i)
      end

      # Finds all +HydraAttribute::HydraSet+ models for the following +hydra_attribute_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_attribute_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_sets_by_hydra_attribute_id(hydra_attribute_id)
        get_from_nested_cache_or_load_all_models(:hydra_sets_by_hydra_attribute_id, hydra_attribute_id.to_i)
      end

      # Finds all +hydra_attribute_id+ which are connected to +hydra_set+id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_set_id
      # @return [Array<Fixnum>] collection of +hydra_attribute_id+
      def hydra_attribute_ids_by_hydra_set_id(hydra_set_id)
        get_from_nested_cache_or_load_all_models(:hydra_attribute_ids_by_hydra_set_id, hydra_set_id.to_i)
      end

      # Finds all +hydra_set_id+ which are connected to +hydra_attribute_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_attribute_id
      # @return [Array<Fixnum>] collection of +hydra_set_id+
      def hydra_set_ids_by_hydra_attribute_id(hydra_attribute_id)
        get_from_nested_cache_or_load_all_models(:hydra_set_ids_by_hydra_attribute_id, hydra_attribute_id.to_i)
      end

      def has_hydra_attribute_id_in_hydra_set_id?(hydra_attribute_id, hydra_set_id)
        hydra_attribute_ids = get_from_nested_cache_or_load_all_models(:hydra_attribute_ids_by_hydra_set_id_as_hash, hydra_set_id.to_i)
        hydra_attribute_ids and hydra_attribute_ids.has_key?(hydra_attribute_id.to_i)
      end

      def has_hydra_set_id_in_hydra_attribute_id?(hydra_set_id, hydra_attribute_id)
        hydra_set_ids = get_from_nested_cache_or_load_all_models(:hydra_set_ids_by_hydra_attribute_id_as_hash, hydra_attribute_id.to_i)
        hydra_set_ids and hydra_set_ids.has_key?(hydra_set_id.to_i)
      end

      # Remove hydra attribute from the cache
      def hydra_attribute_destroyed(hydra_attribute) #:nodoc:
        hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute.id).each(&:destroy)
      end

      # Remove hydra set from the cache
      def hydra_set_destroyed(hydra_set) #:nodoc:
        hydra_attribute_sets_by_hydra_set_id(hydra_set.id).each(&:destroy)
      end

      private
        def add_to_hydra_attribute_sets_by_hydra_attribute_id_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_attribute_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id] ||= []
          nested_identity_map(:hydra_attribute_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id] << hydra_attribute_set
        end

        def delete_from_hydra_attribute_sets_by_hydra_attribute_id_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_attribute_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id]
          nested_identity_map(:hydra_attribute_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id].delete(hydra_attribute_set)
        end

        def add_to_hydra_attribute_sets_by_hydra_set_id_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_attribute_sets_by_hydra_set_id)[hydra_attribute_set.hydra_set_id] ||= []
          nested_identity_map(:hydra_attribute_sets_by_hydra_set_id)[hydra_attribute_set.hydra_set_id] << hydra_attribute_set
        end

        def delete_from_hydra_attribute_sets_by_hydra_set_id_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_attribute_sets_by_hydra_set_id)[hydra_attribute_set.hydra_set_id]
          nested_identity_map(:hydra_attribute_sets_by_hydra_set_id)[hydra_attribute_set.hydra_set_id].delete(hydra_attribute_set)
        end

        def add_to_hydra_attributes_by_hydra_set_id_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_attributes_by_hydra_set_id)[hydra_attribute_set.hydra_set_id] ||= []
          nested_identity_map(:hydra_attributes_by_hydra_set_id)[hydra_attribute_set.hydra_set_id] << hydra_attribute_set.hydra_attribute
        end

        def delete_from_hydra_attributes_by_hydra_set_id_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_attributes_by_hydra_set_id)[hydra_attribute_set.hydra_set_id]
          nested_identity_map(:hydra_attributes_by_hydra_set_id)[hydra_attribute_set.hydra_set_id].delete(hydra_attribute_set.hydra_attribute)
        end

        def add_to_hydra_sets_by_hydra_attribute_id_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id] ||= []
          nested_identity_map(:hydra_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id] << hydra_attribute_set.hydra_set
        end

        def delete_from_hydra_sets_by_hydra_attribute_id_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id]
          nested_identity_map(:hydra_sets_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id].delete(hydra_attribute_set.hydra_set)
        end

        def add_to_hydra_attribute_ids_by_hydra_set_id_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_attribute_ids_by_hydra_set_id)[hydra_attribute_set.hydra_set_id] ||= []
          nested_identity_map(:hydra_attribute_ids_by_hydra_set_id)[hydra_attribute_set.hydra_set_id] << hydra_attribute_set.hydra_attribute_id
        end

        def delete_from_hydra_attribute_ids_by_hydra_set_id_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_attribute_ids_by_hydra_set_id)[hydra_attribute_set.hydra_set_id]
          nested_identity_map(:hydra_attribute_ids_by_hydra_set_id)[hydra_attribute_set.hydra_set_id].delete(hydra_attribute_set.hydra_attribute_id)
        end

        def add_to_hydra_set_ids_by_hydra_attribute_id_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_set_ids_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id] ||= []
          nested_identity_map(:hydra_set_ids_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id] << hydra_attribute_set.hydra_set_id
        end

        def delete_from_hydra_set_ids_by_hydra_attribute_id_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_set_ids_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id]
          nested_identity_map(:hydra_set_ids_by_hydra_attribute_id)[hydra_attribute_set.hydra_attribute_id].delete(hydra_attribute_set.hydra_set_id)
        end

        def add_to_hydra_attribute_ids_by_hydra_set_id_as_hash_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_attribute_ids_by_hydra_set_id_as_hash)[hydra_attribute_set.hydra_set_id] ||= {}
          nested_identity_map(:hydra_attribute_ids_by_hydra_set_id_as_hash)[hydra_attribute_set.hydra_set_id][hydra_attribute_set.hydra_attribute_id] = nil
        end

        def delete_from_hydra_attribute_ids_by_hydra_set_id_as_hash_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_attribute_ids_by_hydra_set_id_as_hash)[hydra_attribute_set.hydra_set_id]
          nested_identity_map(:hydra_attribute_ids_by_hydra_set_id_as_hash)[hydra_attribute_set.hydra_set_id].delete(hydra_attribute_set.hydra_attribute_id)
        end

        def add_to_hydra_set_ids_by_hydra_attribute_id_as_hash_cache(hydra_attribute_set)
          return if hydra_attribute_set.destroyed?
          return unless identity_map.has_key?(:all)
          nested_identity_map(:hydra_set_ids_by_hydra_attribute_id_as_hash)[hydra_attribute_set.hydra_attribute_id] ||= {}
          nested_identity_map(:hydra_set_ids_by_hydra_attribute_id_as_hash)[hydra_attribute_set.hydra_attribute_id][hydra_attribute_set.hydra_set_id] = nil
        end

        def delete_from_hydra_set_ids_by_hydra_attribute_id_as_hash_cache(hydra_attribute_set)
          return unless nested_identity_map(:hydra_set_ids_by_hydra_attribute_id_as_hash)[hydra_attribute_set.hydra_attribute_id]
          nested_identity_map(:hydra_set_ids_by_hydra_attribute_id_as_hash)[hydra_attribute_set.hydra_attribute_id].delete(hydra_attribute_set.hydra_set_id)
        end
    end

    # Returns hydra attribute for this relation
    #
    # @return [HydraAttribute::HydraAttribute, NilClass]
    def hydra_attribute
      ::HydraAttribute::HydraAttribute.find(hydra_attribute_id) if hydra_attribute_id
    end

    # Returns hydra set for this relation
    #
    # @return [HydraAttribute::HydraSet, NilClass]
    def hydra_set
      ::HydraAttribute::HydraSet.find(hydra_set_id) if hydra_set_id
    end
  end
end