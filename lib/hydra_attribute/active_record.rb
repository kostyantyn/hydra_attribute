module HydraAttribute
  module ActiveRecord
    def use_hydra_attributes
      Builder.new(self).build
    end
  end
end