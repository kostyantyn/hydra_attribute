module HydraAttribute
  module Cucumber
    module World
      def typecast_value(schema)
        type, value = schema.gsub(/\[|\]/, '').split(':')
        case type
        when 'integer' then value.to_i
        when 'float'   then value.to_f
        when 'boolean' then value == 'true' ? true : false
        when 'nil'     then nil
        else value
        end
      end

      def typecast_attribute(attribute)
        name, schema = attribute.split('=')
        [name, typecast_value(schema)]
      end

      def typecast_attributes(*attributes)
        attributes.flatten.each_with_object({}) do |attribute, hash|
          name, value = typecast_attribute(attribute)
          hash[name]  = value
        end
      end
    end
  end
end

World(HydraAttribute::Cucumber::World)