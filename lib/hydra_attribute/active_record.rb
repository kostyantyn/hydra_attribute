module HydraAttribute
  module ActiveRecord
    def use_hydra_attributes
      Builder.build(self)
    end
  end
end