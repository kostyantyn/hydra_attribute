module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      included do
        @hydra_attributes = {}

        include Read
        include BeforeTypeCast
      end

      module ClassMethods
        def inherited(base)
          base.instance_variable_set(:@hydra_attributes, hydra_attributes)
          super
        end

        def hydra_attributes
          @hydra_attributes.dup
        end

        def hydra_attribute_names
          hydra_attributes.keys
        end

        def hydra_attribute_types
          hydra_attributes.values.uniq
        end
      end

      def initialize(attributes = nil, options = {})
        @hydra_attribute_names = self.class.hydra_attribute_names
        super
      end

      def init_with(coder)
        @hydra_attribute_names = self.class.hydra_attribute_names
        super
      end

      def initialize_dup(other)
        if other.instance_variable_defined?(:@hydra_attribute_names)
          @hydra_attribute_names = other.instance_variable_get(:@hydra_attribute_names)
        else
          @hydra_attribute_names = self.class.hydra_attribute_names
        end
        super
      end

      def hydra_attribute_model(name, type)
        collection = send(HydraAttribute.config.association(type))
        collection.detect { |model| model.name == name } || collection.build(name: name)
      end

      def attributes
        super.merge(hydra_attributes)
      end

      %w(attributes attributes_before_type_cast).each do |attr_method|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_#{attr_method}
            @hydra_attribute_names.each_with_object({}) do |name, attributes|
              type = self.class.hydra_attributes[name]
              attributes[name] = hydra_attribute_model(name, type).#{attr_method}['value']
            end
          end
        EOS
      end
    end
  end
end