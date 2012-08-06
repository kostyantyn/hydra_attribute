module HydraAttribute
  module Cucumber
    module World
      def type_cast_value(schema)
        return schema unless schema.is_a?(String)
        type, value = schema.gsub(/\[|\]/, '').split(':', 2)
        return schema if schema == type && value.nil?

        case type
        when 'integer'  then value.to_i
        when 'float'    then value.to_f
        when 'boolean'  then value == 'true' ? true : false
        when 'nil'      then nil
        when 'datetime' then ActiveSupport::TimeZone.new('UTC').parse(value)
        when 'symbol'   then value.to_sym
        else value
        end
      end

      def type_cast_attribute(attribute)
        name, schema = attribute.split('=')
        [name, type_cast_value(schema)]
      end

      def type_cast_attributes(attributes)
        attributes.split(/(?<=\])\s+/).flatten.each_with_object({}) do |attribute, hash|
          name, value = type_cast_attribute(attribute)
          hash[name]  = value
        end
      end

      def type_cast_hash(hash)
        hash.delete_if{ |_, v| v.blank? }.each do |key, value|
          hash[key] = type_cast_value(value)
        end
      end

      def redefine_hydra_entity(klass)
        ::ActiveSupport::Dependencies.clear

        Object.send(:remove_const, klass.to_sym) if Object.const_defined?(klass.to_sym)

        ::HydraAttribute::SUPPORT_TYPES.each do |type|
          class_name = "Hydra#{type.capitalize}#{klass}".to_sym
          ::HydraAttribute.send(:remove_const, class_name) if ::HydraAttribute.const_defined?(class_name)
        end

        Object.const_set(klass.to_sym, Class.new(::ActiveRecord::Base))
        klass.to_s.constantize.send(:accessible_attributes_configs).values.each(&:clear)
        klass.to_s.constantize.attr_accessible :name
        klass.to_s.constantize.send(:include, ::HydraAttribute::ActiveRecord)
      end
    end
  end
end

World(HydraAttribute::Cucumber::World)