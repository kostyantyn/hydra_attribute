module HydraAttribute
  module ActiveRecord
    class Reflection < ::ActiveRecord::Reflection::AssociationReflection

      # Return custom association class
      # which is optimized to load hydra attributes
      def association_class
        Association
      end

      def backend_type
        @backend_type ||= SUPPORTED_BACKEND_TYPES.find { |type| type == klass.model_name.demodulize.underscore.split('_')[1] }
      end
    end
  end
end