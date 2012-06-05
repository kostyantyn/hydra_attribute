module HydraAttribute
  class AttributeBuilder
    NAME_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?=]?\z/
    CALL_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?]?\z/

    attr_reader :klass, :name, :type

    def initialize(klass, name, type)
      @klass, @name, @type = klass, name.to_s, type
    end

    def build
      define_attribute_methods
      save_attribute
    end

    private

    def define_attribute_methods
      m = Module.new
      @klass.attribute_method_matchers.each do |matcher|
        current = matcher.method_name(name)
        target  = matcher.method_name(:value)

        if current =~ NAME_COMPILABLE_REGEXP
          defn = "def #{current}(*args)"
        else
          defn = "define_method(:'#{current}') do |*args|"
        end

        if target =~ CALL_COMPILABLE_REGEXP
          send = "#{target}(*args)"
        else
          send = "send(:'#{target}', *args)"
        end

        body = "hydra_attribute_model('#{name}', :#{type}).#{send}"
        if current.end_with?('=')
          body = "v = #{body}; @hydra_attribute_names << '#{name}' unless @hydra_attribute_names.include?('#{name}'); v"
        else
          body.insert(0, "missing_attribute('#{name}', caller) unless @hydra_attribute_names.include?('#{name}'); ")
        end

        m.class_eval <<-EOS, __FILE__, __LINE__ + 1
          #{defn}
            #{body}
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