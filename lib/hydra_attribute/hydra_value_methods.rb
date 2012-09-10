module HydraAttribute
  module HydraValueMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # Clear cache
      #
      # @return [NilClass]
      def clear_hydra_value_cache!
      end
    end

    # Returns the association instance for the given backend type attribute name
    #
    # @param backend_type [String] one of the HydraAttribute::SUPPORTED_BACKEND_TYPES values
    # @return [ActiveRecord::Associations::Association]
    def hydra_value_association(backend_type)
      association(::HydraAttribute::AssociationBuilder.association_name(backend_type))
    end
  end
end