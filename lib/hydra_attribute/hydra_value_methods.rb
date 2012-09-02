module HydraAttribute
  module HydraValueMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def clear_hydra_value_cache!
      end
    end

    def hydra_value_association(backend_type)
      association(::HydraAttribute::AssociationBuilder.association_name(backend_type))
    end
  end
end