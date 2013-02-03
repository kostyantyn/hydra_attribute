module HydraAttribute
  class HydraAttributeSet
    include Model

    nested_cache_keys :hydra_attribute, :hydra_set

    observe 'HydraAttribute::HydraAttribute', after_destroy: :hydra_attribute_destroyed
    observe 'HydraAttribute::HydraSet',       after_destroy: :hydra_set_destroyed

    validates :hydra_set_id,       presence: true
    validates :hydra_attribute_id, presence: true, unique: { scope: :hydra_set_id }

    class << self
      # Finds all records which have relation to the following hydra set ID
      # This method is cacheable
      #
      # @param [Fixnum] hydra_set_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_attribute_sets_by_hydra_set_id(hydra_set_id)
        hydra_set_cache(hydra_set_id.to_i) do
          all.select { |model| model.hydra_set_id == hydra_set_id.to_i }
        end
      end

      # Finds all records which have relation to the following hydra attribute ID
      # This method is cacheable
      #
      # @param [Fixnum] hydra_attribute_id
      # @return [Array<HydraAttribute::HydraSet>]
      def hydra_attribute_sets_by_hydra_attribute_id(hydra_attribute_id)
        hydra_attribute_cache(hydra_attribute_id.to_i) do
          all.select { |model| model.hydra_attribute_id == hydra_attribute_id.to_i }
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

      if self.class.hydra_attribute_identity_map[hydra_attribute_id]
        self.class.hydra_attribute_identity_map[hydra_attribute_id].push(self)
      end

      if self.class.hydra_set_identity_map[hydra_set_id]
        self.class.hydra_set_identity_map[hydra_set_id].push(self)
      end

      id
    end

    # Deletes relation object
    # Removes it from the cache
    #
    # @return [TrueClass]
    def delete
      result = super
      if self.class.hydra_attribute_identity_map[hydra_attribute_id]
        self.class.hydra_attribute_identity_map[hydra_attribute_id].delete(self)
      end

      if self.class.hydra_set_identity_map[hydra_set_id]
        self.class.hydra_set_identity_map[hydra_set_id].delete(self)
      end

      result
    end

    # Returns hydra attribute for this relation
    #
    # @return [HydraAttribute::HydraAttribute, NilClass]
    def hydra_attribute
      ::HydraAttribute::HydraAttribute.find(hydra_attribute_id) if persisted?
    end

    # Returns hydra set for this relation
    #
    # @return [HydraAttribute::HydraSet, NilClass]
    def hydra_set
      ::HydraAttribute::HydraSet.find(hydra_set_id) if persisted?
    end
  end
end