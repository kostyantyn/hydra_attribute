module HydraAttribute
  class HydraSet
    include ::HydraAttribute::Model

    validates :entity_type, presence: true
    validates :name,        presence: true, unique: { scope: :entity_type }

    # Returns collection of hydra attributes for this hydra set
    #
    # @return [Array<HydraAttribute::HydraAttribute>]
    def hydra_attributes
      if id?
        HydraAttributeSet.hydra_attributes_by_hydra_set_id(id)
      else
        []
      end
    end

  end
end