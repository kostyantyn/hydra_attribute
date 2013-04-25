module HydraAttribute
  module Model
    module Dirty
      extend ActiveSupport::Concern

      module ClassMethods
        # Defines dirty method
        #
        # @param [String] column_name
        # @return [NilClass]
        def define_attribute_method(column_name)
          super(column_name)
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{column_name}_was
              @attributes_were[:#{column_name}]
            end

            def #{column_name}_changed?
              @attributes_were[:#{column_name}] != @attributes[:#{column_name}]
            end
          EOS
        end
      end

      # Redefine initializer for catching previous attributes
      def initialize(attributes = {})
        super(attributes)
        @attributes_were = @attributes.clone
      end

      # Update previous attributes after saving
      def save
        result = super
        @attributes_were = @attributes.clone
        result
      end
    end
  end
end