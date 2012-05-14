module HydraAttribute
  class Attribute
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
      @klass.instance_variable_defined?(:@hydra_attributes)
    end

    def define_reflection_methods
      hydra_attributes = @klass.instance_variable_set(:@hydra_attributes, Hash.new { |h, k| h[k] = [] })

      @klass.define_singleton_method :hydra_attribute_names do
        hydra_attributes.values.flatten.uniq
      end

      @klass.define_singleton_method :hydra_attribute_types do
        hydra_attributes.keys
      end

      @klass.send :define_method, :hydra_attribute_model do |name, type|
        attributes = send(HydraAttribute.config.association(type))
        attributes.detect { |a| a.name.to_sym == name } || attributes.build(name: name)
      end
    end

    def define_attribute_methods
      m = Module.new
      m.class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{@name};        hydra_attribute_model(:#{@name}, :#{@type}).value          end
        def #{@name}=(value) hydra_attribute_model(:#{@name}, :#{@type}).value = value  end
        def #{@name}?;       hydra_attribute_model(:#{@name}, :#{@type}).value.present? end
      EOS
      @klass.send :include, m
    end

    def save_attribute
      @klass.instance_variable_get(:@hydra_attributes)[@type] << @name
    end
  end
end