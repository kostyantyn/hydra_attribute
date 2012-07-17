module HydraAttribute
  class Configuration
    def self.add_setting(name, default_value)
      attr_writer name

      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{name}
          @#{name} = #{default_value} unless defined?(@#{name})
          @#{name}
        end

        def #{name}?
          #{name}.present?
        end
      EOS
    end
  end
end