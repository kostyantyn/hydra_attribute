module HydraAttribute
  class HydraAttributeValueAssociation
    attr_reader :entity

    def initialize(entity, hydra_values = {})
      @entity       = entity
      @hydra_values = hydra_values
    end

    # Find +HydraAttribute::HydraValue+ model by +hydra_attribute_id+
    # This method checks if hydra attribute is in hydra set list, otherwise raise and error
    #
    # @param [Fixnum] hydra_attribute_id
    # @return [HydraAttribute::HydraValue]
    def hydra_value_by_hydra_attribute_id(hydra_attribute_id)
      unless ::HydraAttribute::HydraAttribute.ids_by_entity_type(entity.class.model_name).include?(hydra_attribute_id)
        raise HydraAttribute::UnknownHydraAttributeIdError, %(Cannot find HydraAttribute::HydraAttribute by ID "#{hydra_attribute_id}")
      end

      unless has_attribute_id?(hydra_attribute_id)
        hydra_attribute = HydraAttribute.find(hydra_attribute_id)
        raise HydraSet::MissingAttributeInHydraSetError, %(HydraAttribute "#{hydra_attribute.name}" is missed in HydraSet "#{hydra_set_id}")
      end

      @hydra_values[hydra_attribute_id] ||= HydraValue.new(entity, hydra_attribute_id: hydra_attribute_id)
    end

    def save
      touch = false
      @hydra_values.each do |hydra_attribute_id, hydra_value|
        if has_attribute_id?(hydra_attribute_id)
          hydra_value.save
          touch = true
        end
      end
      entity.touch if touch
    end

    def destroy
      #HydraValue.delete_for(entity.id)
    end

    private
      def has_attribute_id?(hydra_attribute_id)
        !entity.hydra_set || entity.hydra_set.has_hydra_attribute_id?(hydra_attribute_id)
      end
  end
end