module HydraAttribute
  class Configuration
    def self.add_setting(name, default_value)
      attr_writer name

      define_method name do
        instance_variable_set("@#{name}", default_value) unless instance_variable_defined?("@#{name}")
        instance_variable_get("@#{name}")
      end

      define_method "#{name}?" do
        send(name).present?
      end
    end

    add_setting :table_prefix,                     'hydra_'
    add_setting :association_prefix,               'hydra_'
    add_setting :use_module_for_associated_models, true

    def table_name(type)
      "#{table_prefix}#{type}_attributes".to_sym
    end

    def association(type)
      "#{association_prefix}#{type}_attributes".to_sym
    end

    # Return string for compatibility with ActiveRecord 3.1.x
    def associated_model_name(type)
      klass = associated_const_name(type).to_s
      klass = "HydraAttribute::#{klass}" if use_module_for_associated_models?
      klass
    end

    def associated_const_name(type)
      "#{type.to_s.titlecase}Attribute".to_sym
    end

    def relation_execute_method
      if ::ActiveRecord::VERSION::MINOR > 1
        :exec_queries
      else
        :to_a
      end
    end
  end
end