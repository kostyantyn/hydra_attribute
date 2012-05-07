module HydraAttribute
  module ActiveRecord
    def hydra_attributes
      yield Builder.new(self)
    end
  end
end