module HydraAttribute
  module Cucumber
    module World
      def typecast_value(schema)
        type, value = schema.gsub(/\[|\]/, '').split(':', 2)
        case type
        when 'integer'  then value.to_i
        when 'float'    then value.to_f
        when 'boolean'  then value == 'true' ? true : false
        when 'nil'      then nil
        when 'datetime' then ActiveSupport::TimeZone.new('UTC').parse(value)
        else value
        end
      end

      def typecast_attribute(attribute)
        name, schema = attribute.split('=')
        [name.to_sym, typecast_value(schema)]
      end

      def typecast_attributes(attributes)
        attributes.split(/(?<=\])\s+/).flatten.each_with_object({}) do |attribute, hash|
          name, value = typecast_attribute(attribute)
          hash[name]  = value
        end
      end
    end
  end
end

World(HydraAttribute::Cucumber::World)