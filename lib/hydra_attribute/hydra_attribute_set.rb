module HydraAttribute
  class HydraAttributeSet
    include Model

    validates :hydra_set_id,       presence: true
    validates :hydra_attribute_id, presence: true, unique: { scope: :hydra_set_id }
  end
end