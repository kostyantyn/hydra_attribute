module HydraAttribute
  class HydraAttribute
    include Model

    validates :entity_type,  presence: true
    validates :name,         presence: true, unique: { scope: :entity_type }
    validates :backend_type, presence: true, inclusion: { in: ::HydraAttribute::SUPPORTED_BACKEND_TYPES }

    # Returns collection of hydra sets for this hydra attribute
    #
    # @return [Array<HydraAttribute::HydraSet>]
    def hydra_sets
      if id?
        HydraAttributeSet.hydra_sets_by_hydra_attribute_id(id)
      else
        []
      end
    end
  end
end