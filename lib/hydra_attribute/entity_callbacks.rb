module HydraAttribute
  module EntityCallbacks
    extend ActiveSupport::Concern

    included do
      after_create   :create_hydra_values
      after_update   :update_hydra_values
      before_destroy :destroy_hydra_values
    end

    private

    def create_hydra_values
      created = false
      each_hydra_value_model do |model|
        model.entity_id = id
        model.save
        created = true
      end
      touch if created
    end

    def update_hydra_values
      updated = false
      each_hydra_value_model do |model|
       if model.changed?
         updated = true
         model.save
       end
      end
      touch if updated
    end

    def destroy_hydra_values
      self.class.hydra_attribute_backend_types.each do |type|
        AssociationBuilder.class_name(self.class, type).constantize.where(entity_id: id).delete_all
      end
    end

    def each_hydra_value_model(&block)
      self.class.hydra_attribute_backend_types.each do |type|
        association(AssociationBuilder.association_name(type)).all_models.each(&block)
      end
    end
  end
end