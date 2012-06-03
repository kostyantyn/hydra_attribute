module HydraAttribute
  module AttributeHelpers
    extend ActiveSupport::Concern

    included do
      @hydra_attributes = {}
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

    def hydra_attribute_model(name, type)
      collection = send(HydraAttribute.config.association(type))
      collection.detect { |model| model.name.to_sym == name } || collection.build(name: name)
    end

    %w(attributes attributes_before_type_cast).each do |attr_method|
      module_eval <<-EOS, __FILE__, __LINE__ + 1
        def hydra_#{attr_method}
          self.class.hydra_attributes.each_with_object({}) do |(name, type), attributes|
            attributes[name.to_s] = hydra_attribute_model(name, type).#{attr_method}['value']
          end
        end
      EOS
    end
  end
end