module HydraAttribute
  module ActiveRecord
    def define_hydra_attributes(&block)
      Builder.new(self).instance_eval(&block)
    end
  end
end