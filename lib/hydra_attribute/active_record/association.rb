module HydraAttribute
  module ActiveRecord
    class Association < ::ActiveRecord::Associations::HasManyAssociation

      def find_model(attributes = {})
        load_target unless loaded?
        target.detect do |model|
          model.hydra_attribute_id == attributes[:hydra_attribute_id]
        end
      end

      def find_model_or_build(attributes = {})
        find_model(attributes) || build(attributes)
      end

      def build(attributes = {}, options = {}, &block)
        return if locked_for_build? and white_list_for_build.exclude?(attributes[:hydra_attribute_id])
        super
      end

      def all_models
        unless @full_loaded
          (all_attribute_ids - target.map(&:hydra_attribute_id)).each do |hydra_attribute_id|
            build(hydra_attribute_id: hydra_attribute_id)
          end
          @full_loaded = true
        end
        target
      end

      def locked_for_build
        @locked_for_build ||= false
      end
      alias_method :locked_for_build?, :locked_for_build

      def lock_for_build!(white_list_for_build = [])
        @locked_for_build     = true
        @white_list_for_build = Array(white_list_for_build)
        loaded!
      end

      def white_list_for_build
        @white_list_for_build ||= []
      end

      def all_attribute_ids
        locked_for_build ? white_list_for_build : owner.class.hydra_attribute_ids
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
      def build_record(attributes, _)
        reflection.klass.new do |record|
          default_value = owner.class.hydra_attribute(attributes[:hydra_attribute_id]).default_value
          attributes.reverse_merge(value: default_value).each do |name, value|
            record.send(:write_attribute, name, value)
          end
        end
      end
    end
  end
end