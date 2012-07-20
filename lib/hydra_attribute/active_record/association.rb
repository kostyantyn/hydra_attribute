module HydraAttribute
  module ActiveRecord
    class Association < ::ActiveRecord::Associations::HasManyAssociation

      def detect(options = {})
        load_target unless loaded!
        target.detect { |model| model.hydra_attribute_id == options[:hydra_attribute_id] }
      end

      def detect_or_build(options = {})
        detect(options) || build(options)
      end

      private

      # Optimized method
      # Remove unnecessary callbacks
      def add_to_target(record)
        @target << record
        record
      end

      # Optimized record
      # Attributes are written via low level function without additional checks
      def build_record(attributes, options)
        reflection.klass.new do |record|
          attributes.each do |name, value|
            record.send(:write_attribute, name, value)
          end
        end
      end
    end
  end
end