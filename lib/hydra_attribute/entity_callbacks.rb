module HydraAttribute
  module EntityCallbacks
    extend ActiveSupport::Concern

    included do
      after_create   :save_hydra_values
      after_update   :save_hydra_values
      before_destroy :destroy_hydra_values
    end

    private

    def save_hydra_values
      changed = false
      self.class.hydra_set_attribute_backend_types(hydra_set_id).each do |backend_type|
        changed = true if hydra_value_association(backend_type).save
      end
      touch if changed
    end

    def destroy_hydra_values
      self.class.hydra_attribute_backend_types.each do |backend_type|
        AssociationBuilder.class_name(self.class, backend_type).constantize.where(entity_id: id).delete_all
      end
    end
  end
end