module HydraAttribute
  class Attribute
    NAME_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?=]?\z/
    CALL_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?]?\z/

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
      @klass.attribute_method_matchers.each do |matcher|
        defn = matcher.method_name(name)
        send = matcher.method_name(:value)

        if defn =~ NAME_COMPILABLE_REGEXP
          defn = "def #{defn}(*args)"
        else
          defn = "define_method(:'#{defn}') do |*args|"
        end

        if send =~ CALL_COMPILABLE_REGEXP
          send = "#{send}(*args)"
        else
          send = "send(:'#{send}', *args)"
        end

        m.class_eval <<-EOS, __FILE__, __LINE__ + 1
          #{defn}
            hydra_attribute_model(:#{name}, :#{type}).#{send}
          end
        EOS
      end
      klass.send :include, m
    end

    def save_attribute
      klass.instance_variable_get(:@hydra_attributes)[name] = type
    end
  end
end