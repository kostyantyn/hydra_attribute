module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      # Returns type casted attributes
      #
      # @return [Hash]
      def attributes
        super.merge(hydra_attributes)
      end

      # Returns attributes before type casting
      #
      # @return [Hash]
      def attributes_before_type_cast
        super.merge(hydra_attributes_before_type_cast)
      end

      # Read type cast attribute value by its name
      #
      # @param [String,Symbol] name
      # @return [Hash]
      def read_attribute(name)
        name = name.to_s
        if hydra_attributes.has_key?(name)
          hydra_attributes[name]
        else
          super
        end
      end
    end
  end
end