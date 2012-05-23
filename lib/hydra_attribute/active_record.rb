module HydraAttribute
  module ActiveRecord
    def define_hydra_attributes
      yield Builder.new(self)
    end
  end
end