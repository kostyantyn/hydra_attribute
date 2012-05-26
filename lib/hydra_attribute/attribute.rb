module HydraAttribute
  class Attribute
    attr_reader :klass, :name, :type

    def initialize(klass, name, type)
      @klass, @name, @type = klass, name, type
    end

    def build
      define_attribute_methods
      save_attribute
    end

    private

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