module HydraAttribute
  module ActiveRecord
    class Reflection < ::ActiveRecord::Reflection::AssociationReflection

      # Return custom association class
      # which is optimized to load hydra attributes
      def association_class
        Association
      end
    end
  end
end