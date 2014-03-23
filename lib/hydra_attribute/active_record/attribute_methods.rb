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

      # Assigns attributes to the model
      #
      # @param [Hash] new_attributes
      # @return [NilClass]
      def assign_attributes(new_attributes)
        if new_attributes[:hydra_set_id]
          # set :hydra_set_id attribute as a last attribute to avoid HydraAttribute::HydraSet::MissingAttributeInHydraSetError error
          new_attributes[:hydra_set_id] = new_attributes.delete(:hydra_set_id)
        end
        super
      end

      # Returns the column object for the named attribute.
      #
      # @param [String, Symbol] name
      # @return [ActiveRecord::ConnectionAdapters::Column]
      def column_for_attribute(name)
        hydra_attribute = self.class.hydra_attributes.find { |hydra_attribute| hydra_attribute.name == name.to_s } # TODO should be cached
        if hydra_attribute
          HydraValue.column(hydra_attribute.id)
        else
          super
        end
      end

      # Returns an <tt>#inspect</tt>-like string for the attribute value.
      #
      # @param [String, Symbol] attr_name
      # @return [String]
      def attribute_for_inspect(attr_name)
        if hydra_attributes.has_key?(attr_name.to_s)
          value = hydra_attributes[attr_name.to_s]
          if value.is_a?(String) && value.length > 50
            "#{value[0..50]}...".inspect
          elsif value.is_a?(Date) || value.is_a?(Time)
            %("#{value.to_s(:db)}")
          else
            value.inspect
          end
        else
          super
        end
      end
    end
  end
end
