module HydraAttribute
  module ActiveRecord
    def using_hydra_attributes
      Builder.new(self).build
    end
  end
end