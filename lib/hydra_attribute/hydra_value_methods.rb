module HydraAttribute
  module HydraValueMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def clear_hydra_value_cache!
      end
    end

    def hydra_value_model(identifier)
      @hydra_value_model ||= {}
      @hydra_value_model[identifier] ||= begin
        hydra_attribute = self.class.hydra_attribute(identifier)
        if hydra_attribute
          association = hydra_value_association(hydra_attribute.backend_type)
          association.find_model_or_build(hydra_attribute_id: hydra_attribute.id)
        end
      end
    end

    def hydra_value_models
      @hydra_value_models ||= self.class.hydra_set_attribute_backend_types(hydra_set_id).inject([]) do |models, backend_type|
        models + hydra_value_association(backend_type).all_models
      end
    end

    def hydra_value_association(backend_type)
      association(::HydraAttribute::AssociationBuilder.association_name(backend_type))
    end
  end
end