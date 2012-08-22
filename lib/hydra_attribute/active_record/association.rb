module HydraAttribute
  module ActiveRecord
    class Association < ::ActiveRecord::Associations::HasManyAssociation

      def find_model(hydra_attribute_id)
        load_target unless loaded?

        hydra_set_target.detect do |model|
          model.hydra_attribute_id == hydra_attribute_id
        end
      end

      def find_model_or_build(options = {})
        find_model(options[:hydra_attribute_id]) || build(options)
      end

      def build(attributes = {}, options = {}, &block)
        return if hydra_attribute_ids.exclude?(attributes[:hydra_attribute_id])
        return if target.any? { |model| model.hydra_attribute_id == attributes[:hydra_attribute_id] }

        super
      end

      def all_models
        unless @full_loaded
          (hydra_attribute_ids - target.map(&:hydra_attribute_id)).each do |hydra_attribute_id|
            build(hydra_attribute_id: hydra_attribute_id)
          end
          @full_loaded = true
        end
        hydra_set_target
      end

      def save
        changed = false
        all_models.each do |model|
          model.entity_id = owner.id
          model.save
          changed = true unless model.previous_changes.blank?
        end
        changed
      end

      def lock!(white_list = [])
        @white_list = Array(white_list)
        loaded!
      end

      def hydra_attributes
        if @white_list
          @hydra_attributes ||= owner.class.hydra_set_attributes_for_backend_type(owner.hydra_set_id, reflection.backend_type)
        else
          owner.class.hydra_set_attributes_for_backend_type(owner.hydra_set_id, reflection.backend_type)
        end
      end

      def hydra_attribute_ids
        if @white_list
          @hydra_attribute_ids ||= owner.class.hydra_set_attribute_ids_for_backend_type(owner.hydra_set_id, reflection.backend_type) & @white_list
        else
          owner.class.hydra_set_attribute_ids_for_backend_type(owner.hydra_set_id, reflection.backend_type)
        end
      end

      def hydra_attribute_names
        if @white_list
          hydra_attributes.map(&:name)
        else
          owner.class.hydra_set_attribute_names_for_backend_type(owner.hydra_set_id, reflection.backend_type)
        end
      end

      def hydra_set_target
        @hydra_set_target ||= target.select do |model|
          hydra_attribute_ids.include?(model.hydra_attribute_id)
        end
      end

      def clear_cache!
        @hydra_attributes    = nil
        @hydra_attribute_ids = nil
        @full_loaded         = nil
        @hydra_set_target    = nil
      end

      private

      # Optimized method
      # Remove unnecessary callbacks
      def add_to_target(record)
        @target << record
        record
      end

      # Optimized method
      # Attributes are written via low level function without additional checks
      def build_record(options, _)
        reflection.klass.new do |record|
          unless options.has_key?(:value)
            options[:value] = owner.class.hydra_attribute(options[:hydra_attribute_id]).default_value
          end

          record.send :write_attribute, 'id', options[:id]
          record.send :write_attribute, 'entity_id', owner.id
          record.send :write_attribute, 'hydra_attribute_id', options[:hydra_attribute_id]
          record.send :write_attribute, 'value', options[:value]

          hydra_set_target << record unless hydra_set_target.include?(record)
        end
      end
    end
  end
end