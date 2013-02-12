module HydraAttribute
  class HydraAttributeSet
    include ::HydraAttribute::Model

    nested_cache_keys :hydra_attribute, :hydra_set
    nested_cache_keys :hydra_attributes_by_hydra_set_id
    nested_cache_keys :hydra_sets_by_hydra_attribute_id

    observe 'HydraAttribute::HydraAttribute', after_destroy: :hydra_attribute_destroyed
    observe 'HydraAttribute::HydraSet',       after_destroy: :hydra_set_destroyed

    validates :hydra_set_id,       presence: true
    validates :hydra_attribute_id, presence: true, unique: { scope: :hydra_set_id }

    class << self
      # Finds all +HydraAttribute::HydraAttributeSet+ models which have the following +hydra_set_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_set_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_attribute_sets_by_hydra_set_id(hydra_set_id)
        hydra_set_cache(hydra_set_id.to_i) do
          all.select { |model| model.hydra_set_id == hydra_set_id.to_i }
        end
      end

      # Finds all +HydraAttribute::HydraAttributeSet+ models which have the following +hydra_attribute_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_attribute_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id)
        hydra_attribute_cache(hydra_attribute_id.to_i) do
          all.select { |model| model.hydra_attribute_id == hydra_attribute_id.to_i }
        end
      end

      # Finds all +HydraAttribute::HydraAttribute+ models for the following +hydra_set_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_set_id
      # @return [Array<HydraAttribute::HydraAttribute>]
      def hydra_attributes_by_hydra_set_id(hydra_set_id)
        hydra_attributes_by_hydra_set_id_cache(hydra_set_id.to_i) do
          hydra_attribute_sets_by_hydra_set_id(hydra_set_id).map(&:hydra_attribute)
        end
      end

      # Finds all +HydraAttribute::HydraSet+ models for the following +hydra_attribute_id+
      # This method is cacheable
      #
      # @param [Fixnum] hydra_attribute_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_sets_by_hydra_attribute_id(hydra_attribute_id)
        hydra_sets_by_hydra_attribute_id_cache(hydra_attribute_id.to_i) do
          hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id).map(&:hydra_set)
        end
      end

      # Adds +hydra_attribute_set+ into the available caches
      #
      # @param [HydraAttribute::HydraAttributeSet]
      # @return [NilClass]
      def add_to_cache(hydra_attribute_set)
        if hydra_attribute_identity_map[hydra_attribute_set.hydra_attribute_id]
          hydra_attribute_identity_map[hydra_attribute_set.hydra_attribute_id].push(hydra_attribute_set)
        end

        if hydra_set_identity_map[hydra_attribute_set.hydra_set_id]
          hydra_set_identity_map[hydra_attribute_set.hydra_set_id].push(hydra_attribute_set)
        end

        if hydra_attributes_by_hydra_set_id_identity_map[hydra_attribute_set.hydra_set_id]
          hydra_attributes_by_hydra_set_id_identity_map[hydra_attribute_set.hydra_set_id].push(hydra_attribute_set.hydra_attribute)
        end

        if hydra_sets_by_hydra_attribute_id_identity_map[hydra_attribute_set.hydra_attribute_id]
          hydra_sets_by_hydra_attribute_id_identity_map[hydra_attribute_set.hydra_attribute_id].push(hydra_attribute_set.hydra_set)
        end
      end

      # Removes +hydra_attribute_set+ from the available caches
      #
      # @param [HydraAttribute::HydraAttributeSet]
      # @return [NilClass]
      def remove_from_cache(hydra_attribute_set)
        if hydra_attribute_identity_map[hydra_attribute_set.hydra_attribute_id]
          hydra_attribute_identity_map[hydra_attribute_set.hydra_attribute_id].delete(hydra_attribute_set)
        end

        if hydra_set_identity_map[hydra_attribute_set.hydra_set_id]
          hydra_set_identity_map[hydra_attribute_set.hydra_set_id].delete(hydra_attribute_set)
        end

        if hydra_attributes_by_hydra_set_id_identity_map[hydra_attribute_set.hydra_set_id]
          hydra_attributes_by_hydra_set_id_identity_map[hydra_attribute_set.hydra_set_id].delete(hydra_attribute_set.hydra_attribute)
        end

        if hydra_sets_by_hydra_attribute_id_identity_map[hydra_attribute_set.hydra_attribute_id]
          hydra_sets_by_hydra_attribute_id_identity_map[hydra_attribute_set.hydra_attribute_id].delete(hydra_attribute_set.hydra_set)
        end
      end

      # Remove hydra attribute from the cache
      def hydra_attribute_destroyed(hydra_attribute) #:nodoc:
        hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute.id).each(&:destroy)
      end

      # Remove hydra set from the cache
      def hydra_set_destroyed(hydra_set) #:nodoc:
        hydra_attribute_sets_by_hydra_set_id(hydra_set.id).each(&:destroy)
      end
    end

    # Creates a new relation object
    # Saves it into the cache
    #
    # @return [Fixnum] ID
    def create
      id = super
      self.class.add_to_cache(self)
      id
    end

    # Deletes relation object
    # Removes it from the cache
    #
    # @return [TrueClass]
    def delete
      result = super
      self.class.remove_from_cache(self)
      result
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