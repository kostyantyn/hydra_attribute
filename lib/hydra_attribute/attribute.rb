module HydraAttribute
  class Attribute
    attr_reader :klass, :name, :type

    def initialize(klass, name, type)
      @klass, @name, @type = klass, name, type
    end

    def build
      define_reflection_methods unless defined_reflection?
      save_attribute
      define_attribute_methods
    end

    private

    def defined_reflection?
      klass.instance_variable_defined?(:@hydra_attributes)
    end

    def define_reflection_methods
      klass.instance_variable_set(:@hydra_attributes, {})

      klass.define_singleton_method :hydra_attributes do
        @hydra_attributes.dup
      end

      klass.define_singleton_method :hydra_attribute_names do
        hydra_attributes.keys
      end

      klass.define_singleton_method :hydra_attribute_types do
        hydra_attributes.values.uniq
      end

      klass.send :define_method, :hydra_attribute_model do |name, type|
        collection = send(HydraAttribute.config.association(type))
        collection.detect { |model| model.name.to_sym == name } || collection.build(name: name)
      end
    end

    def define_attribute_methods
      m = Module.new
      m.class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{name};        hydra_attribute_model(:#{name}, :#{type}).value          end
        def #{name}=(value) hydra_attribute_model(:#{name}, :#{type}).value = value  end
        def #{name}?;       hydra_attribute_model(:#{name}, :#{type}).value.present? end
      EOS
      klass.send :include, m
    end

    def save_attribute
      klass.instance_variable_get(:@hydra_attributes)[name] = type
    end
  end
end