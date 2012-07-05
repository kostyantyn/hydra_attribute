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
    end
  end
end

World(HydraAttribute::Cucumber::World)