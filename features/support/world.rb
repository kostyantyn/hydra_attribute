module HydraAttribute
  module Cucumber
    module World
      def typecast_attributes(*attributes)
        attributes.flatten.each_with_object({}) do |attribute, hash|
          name, scheme = attribute.split('=')
          type, value  = scheme.gsub(/\[|\]/, '').split(':')
          hash[name.to_sym] = case type
            when 'integer' then value.to_i
            when 'float'   then value.to_f
            when 'boolean' then value == 'true' ? true : false
            when 'nil'     then nil
            else value
          end
        end
      end
    end
  end
end

World(HydraAttribute::Cucumber::World)