module HydraAttribute
  module HydraAttributeMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def hydra_attributes
        @hydra_attributes ||= HydraAttribute.where(entity_type: base_class.model_name)
      end

      def hydra_attribute(identifier)
        @hydra_attribute ||= {}
        @hydra_attribute[identifier] ||= hydra_attributes.find do |hydra_attribute|
          hydra_attribute.id == identifier || hydra_attribute.name == identifier
        end
      end

      def hydra_attribute_backend_types
        @hydra_attribute_backend_types ||= hydra_attributes.map(&:backend_type).uniq
      end

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s
            @hydra_attribute_#{prefix}s ||= hydra_attributes.map(&:#{prefix})
          end
        EOS
      end

      def hydra_attributes_by_backend_type
        @hydra_attributes_by_backend_type ||= hydra_attributes.group_by(&:backend_type)
      end

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s_by_backend_type
            @hydra_attribute_#{prefix}s_by_backend_type ||= hydra_attributes.each_with_object({}) do |hydra_attribute, object|
              object[hydra_attribute.backend_type] ||= []
              object[hydra_attribute.backend_type] << hydra_attribute.#{prefix}
            end
          end
        EOS
      end

      def hydra_attributes_for_backend_type(backend_type)
        hydra_attributes = hydra_attributes_by_backend_type[backend_type]
        hydra_attributes.nil? ? [] : hydra_attributes
      end

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s_for_backend_type(backend_type)
            values = hydra_attribute_#{prefix}s_by_backend_type[backend_type]
            values.nil? ? [] : values
          end
        EOS
      end

      def hydra_set_attributes(hydra_set_id)
        hydra_set = hydra_set(hydra_set_id)
        hydra_set.nil? ? hydra_attributes : hydra_set.hydra_attributes
      end

      %w(id name backend_type).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s(hydra_set_id)
            @hydra_set_attribute_#{prefix}s ||= {}
            @hydra_set_attribute_#{prefix}s[hydra_set_id] ||= hydra_set_attributes(hydra_set_id).map(&:#{prefix})
          end
        EOS
      end

      def hydra_set_attributes_by_backend_type(hydra_set_id)
        @hydra_set_attributes_by_backend_type ||= {}
        @hydra_set_attributes_by_backend_type[hydra_set_id] ||= hydra_set_attributes(hydra_set_id).group_by(&:backend_type)
      end

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s_by_backend_type(hydra_set_id)
            @hydra_set_attribute_#{prefix}s_by_backend_type ||= {}
            @hydra_set_attribute_#{prefix}s_by_backend_type[hydra_set_id] ||= hydra_set_attributes(hydra_set_id).each_with_object({}) do |hydra_attribute, object|
              object[hydra_attribute.backend_type] ||= []
              object[hydra_attribute.backend_type] << hydra_attribute.#{prefix}
            end
          end
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

      def clear_hydra_attribute_cache!
        @hydra_attributes                     = nil
        @hydra_attribute                      = nil
        @hydra_set_attributes_by_backend_type = nil

        %w(id name backend_type).each do |prefix|
          instance_variable_set("@hydra_attribute_#{prefix}s", nil)
          instance_variable_set("@hydra_set_attribute_#{prefix}s", nil)
        end

        %w(id name).each do |prefix|
          instance_variable_set("@hydra_attribute_#{prefix}s_by_backend_type", nil)
          instance_variable_set("@hydra_set_attribute_#{prefix}s_by_backend_type", nil)
        end
      end
    end

    def hydra_attribute?(name)
      self.class.hydra_attribute_names.include?(name.to_s)
    end

    def hydra_attributes
      hydra_value_models.inject({}) do |hydra_attributes, model|
        hydra_attributes[model.hydra_attribute_name] = model.value
        hydra_attributes
      end
    end

    def hydra_attribute_names
      self.class.hydra_set_attribute_names(hydra_set_id)
    end

    def hydra_attribute_backend_types
      self.class.hydra_set_attribute_backend_types(hydra_set_id)
    end
  end
end