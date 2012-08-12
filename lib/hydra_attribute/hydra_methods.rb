module HydraAttribute
  module HydraMethods
    extend ActiveSupport::Concern

    include HydraSetMethods
    include HydraAttributeMethods
    include HydraValueMethods

    module ClassMethods
      def clear_hydra_method_cache!
        clear_hydra_set_cache!
        clear_hydra_attribute_cache!
        clear_hydra_value_cache!
      end
    end
  end
end