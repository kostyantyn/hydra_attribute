module HydraAttribute
  module HydraMethods
    extend ActiveSupport::Concern
    extend Memoize

    include HydraSetMethods
    include HydraAttributeMethods
    include HydraValueMethods

    included do
      alias_method_chain :write_attribute, :hydra_set_id
    end

    module ClassMethods
      extend Memoize

      def hydra_set_attributes(hydra_set_id)
        hydra_set = hydra_set(hydra_set_id)
        hydra_set.nil? ? hydra_attributes : hydra_set.hydra_attributes
      end

      %w(id name backend_type).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s(hydra_set_id)
            hydra_set_attributes(hydra_set_id).map(&:#{prefix})
          end
          hydra_memoize :hydra_set_attribute_#{prefix}s
        EOS
      end

      def hydra_set_attributes_by_backend_type(hydra_set_id)
        hydra_set_attributes(hydra_set_id).group_by(&:backend_type)
      end
      hydra_memoize :hydra_set_attributes_by_backend_type

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s_by_backend_type(hydra_set_id)
            hydra_set_attributes(hydra_set_id).each_with_object({}) do |hydra_attribute, object|
              object[hydra_attribute.backend_type] ||= []
              object[hydra_attribute.backend_type] << hydra_attribute.#{prefix}
            end
          end
          hydra_memoize :hydra_set_attribute_#{prefix}s_by_backend_type
        EOS
      end

      def hydra_set_attributes_for_backend_type(hydra_set_id, backend_type)
        hydra_attributes = hydra_set_attributes_by_backend_type(hydra_set_id)[backend_type]
        hydra_attributes.nil? ? [] : hydra_attributes
      end

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s_for_backend_type(hydra_set_id, backend_type)
            values = hydra_set_attribute_#{prefix}s_by_backend_type(hydra_set_id)[backend_type]
            values.nil? ? [] : values
          end
        EOS
      end

      def clear_hydra_method_cache!
        clear_hydra_set_cache!
        clear_hydra_attribute_cache!
        clear_hydra_value_cache!

        [
          :@hydra_set_attributes,
          :@hydra_set_attribute_ids,
          :@hydra_set_attribute_names,
          :@hydra_set_attribute_backend_types,
          :@hydra_set_attributes_by_backend_type,
          :@hydra_set_attribute_ids_by_backend_type,
          :@hydra_set_attribute_names_by_backend_type
        ].each do |variable|
          remove_instance_variable(variable) if instance_variable_defined?(variable)
        end
      end
    end

    def hydra_attributes
      hydra_value_models.inject({}) do |hydra_attributes, model|
        hydra_attributes[model.hydra_attribute_name] = model.value
        hydra_attributes
      end
    end

    %w(ids names backend_types).each do |prefix|
      module_eval <<-EOS, __FILE__, __LINE__ + 1
        def hydra_attribute_#{prefix}
          self.class.hydra_set_attribute_#{prefix}(hydra_set_id)
        end
      EOS
    end

    def hydra_value_model(identifier)
      hydra_attribute = self.class.hydra_attribute(identifier)
      if hydra_attribute
        association = hydra_value_association(hydra_attribute.backend_type)
        association.find_model_or_build(hydra_attribute_id: hydra_attribute.id)
      end
    end
    hydra_memoize :hydra_value_model

    def hydra_value_models
      self.class.hydra_set_attribute_backend_types(hydra_set_id).inject([]) do |models, backend_type|
        models + hydra_value_association(backend_type).all_models
      end
    end
    hydra_memoize :hydra_value_models

    private
      def write_attribute_with_hydra_set_id(attr_name, value)
        if attr_name.to_s == 'hydra_set_id'
          self.class.hydra_attribute_backend_types.each do |backend_type|
            hydra_value_association(backend_type).clear_cache!
          end
          remove_instance_variable(:@hydra_value_models) if instance_variable_defined?(:@hydra_value_models)
        end
        write_attribute_without_hydra_set_id(attr_name, value)
      end
  end
end