module HydraAttribute
  module Model
    module Cache
      extend ActiveSupport::Concern

      included do
        nested_cache_keys :model
      end

      module ClassMethods
        # Finds all records and store them into the cache
        #
        # @return [Array<HydraAttribute::Model>]
        def all
          cache(:all) do
            where_not(id: model_identity_map.keys)
            model_identity_map.values
          end
        end

        # Find record by ID and store it into the cache
        #
        # @return [HydraAttribute::Model]
        def find(id)
          model_cache(id) do
            all
            model_cache(id) { raise RecordNotFound, "Couldn't find #{name} with id=#{id}" }
          end
        end
      end

      # Initialize a model
      # Save it into the cache if it is persisted
      def initialize(attributes = {})
        super(attributes)
        self.class.model_cache(id, self) if persisted?
      end

      # Create new model and store it into the cache
      #
      # @return [Fixnum]
      def create
        self.class.model_cache(super, self)
      end

      # Delete model and remove it from the cache
      #
      # @return [TrueClass]
      def delete
        result = super
        self.class.model_identity_map.delete(id)
        if self.class.identity_map[:all]
          self.class.identity_map[:all].delete_if { |model| model.id == id }
        end
        result
      end
    end
  end
end