module HydraAttribute

  # @see HydraAttribute::HydraAttributeMethods::ClassMethods ClassMethods for documentation.
  module HydraAttributeMethods
    extend ActiveSupport::Concern

    module ClassMethods
      extend Memoize

      # Returns prepared +ActiveRecord::Relation+ object with preloaded attributes for current entity.
      #
      # @note This method is cacheable, so just one request per entity will be sent to the database.
      # @example
      #   Product.hydra_attributes                                               # ActiveRecord::Relation
      #   Product.hydra_attributes.map(&:name)                                   # ["title", "color", ...]
      #   Product.hydra_attributes.create(name: 'title', backend_type: 'string') # Create and return new attribute
      #   Product.hydra_attributes.each(&:destroy)                               # Remove all attributes
      # @return [ActiveRecord::Relation] contains attributes for current entity
      def hydra_attributes
        HydraAttribute.where(entity_type: base_class.model_name)
      end
      hydra_memoize :hydra_attributes

      # Finds <tt>HydraAttribute::HydraAttribute</tt> model by +id+ or +name+. Returns +nil+ for unknown attribute.
      #
      # @note This method is cacheable per +identifier+. It's better to use it instead of manually searching from <tt>hydra_attributes</tt> collection.
      # @example
      #   Product.hydra_attribute('name') # HydraAttribute::HydraAttribute
      #   Product.hydra_attribute('name') # Returns HydraAttribute::HydraAttribute from cache
      #   Product.hydra_attribute(10)     # HydraAttribute::HydraAttribute
      #   Product.hydra_attribute('FAKE') # nil
      #
      #   # It's better to use this method
      #   Product.hydra_attribute('name')
      #   # instead of manually searching
      #   Product.hydra_attributes.detect { |attr| attr.name == 'name' || attr.id == 'id' }
      # @param identifier [String, Integer] accepts attribute name or id
      # @return [HydraAttribute::HydraAttribute, NilClass] attribute model or nil if wasn't found
      def hydra_attribute(identifier)
        hydra_attributes.find do |hydra_attribute|
          hydra_attribute.id == identifier || hydra_attribute.name == identifier
        end
      end
      hydra_memoize :hydra_attribute

      # Returns unique array of attribute backend types.
      #
      # @note This method is cacheable therefore, the definition of values is carried out only once.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      #
      #   Product.hydra_attribute_backend_types # ["string", "integer"]
      # @return [Array<String>}] contains backend types
      def hydra_attribute_backend_types
        hydra_attributes.map(&:backend_type).uniq
      end
      hydra_memoize :hydra_attribute_backend_types

      # @!method hydra_attribute_ids
      # Returns array of attribute ids.
      #
      # @note This method is cacheable therefore, the definition of values is carried out only once.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')     # 1
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')     # 2
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer')  # 3
      #
      #   Product.hydra_attribute_ids # [1, 2, 3]
      # @return [Array<Fixnum>] contains attribute ids

      ##
      # @!method hydra_attribute_names
      # Returns array of attribute names.
      #
      # @note This method is cacheable therefore, the definition of values is carried out only once.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      #
      #   Product.hydra_attribute_names # ["one", "two", "three"]
      # @return [Array<String>] contains attribute names
      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s
            hydra_attributes.map(&:#{prefix})
          end
          hydra_memoize :hydra_attribute_#{prefix}s
        EOS
      end

      # Groups current attributes by backend type.
      #
      # @note This method is cacheable therefore, the group operation is carried out only once.
      # @example
      #   Product.hydra_attributes_by_backend_type
      #   # {"string" => [...], "integer" => [...]}
      # @return [Hash{String => Array<HydraAttribute::HydraAttribute>}] contains grouped attribute models by backend type
      def hydra_attributes_by_backend_type
        hydra_attributes.group_by(&:backend_type)
      end
      hydra_memoize :hydra_attributes_by_backend_type

      # @!method hydra_attribute_ids_by_backend_type
      # Group attribute ids by backend type.
      #
      # @note This method is cacheable therefore, the group operation is carried out only once.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')    # 1
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')    # 2
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer') # 3
      #
      #   Product.hydra_attribute_ids_by_backend_type
      #   # {"string" => [1, 2], "integer" => [3]}
      # @return [Hash{String => Array<Fixnum>}] contains grouped attribute ids by backend type

      # @!method hydra_attribute_names_by_backend_type
      # Group attribute names by backend type.
      #
      # @note This method is cacheable therefore, the group operation is carried out only once.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      #
      #   Product.hydra_attribute_names_by_backend_type
      #   # {"string" => ["one", "two"], "integer" => ["three"]}
      # @return [Hash{String => Array<String>}] contains grouped attribute names by backend type
      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s_by_backend_type
            hydra_attributes.each_with_object({}) do |hydra_attribute, object|
              object[hydra_attribute.backend_type] ||= []
              object[hydra_attribute.backend_type] << hydra_attribute.#{prefix}
            end
          end
          hydra_memoize :hydra_attribute_#{prefix}s_by_backend_type
        EOS
      end

      # Returns array of attributes for passed backend type.
      #
      # @note If no attributes, returns blank array.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      #
      #   Product.hydra_attributes_for_backend_type('string')
      #   # [<HydraAttribute::HydraAttribute id: 1, name: "one", ...>, <HydraAttribute::HydraAttribute id: 2, name: "two", ...>]
      #
      #   Product.hydra_attributes_for_backend_type('float') # []
      # @param backend_type [String] backend type of attributes
      # @return [Array<HydraAttribute::HydraAttribute>] contains attribute models for passed backend type
      def hydra_attributes_for_backend_type(backend_type)
        hydra_attributes = hydra_attributes_by_backend_type[backend_type]
        hydra_attributes.nil? ? [] : hydra_attributes
      end

      # @!method hydra_attribute_ids_for_backend_type(backend_type)
      # Returns array of attribute ids for passed backend type.
      #
      # @note If no attributes, returns blank array.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')    # 1
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')    # 2
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer') # 3
      #
      #   Product.hydra_attributes_for_backend_type('string') # [1, 2]
      #   Product.hydra_attributes_for_backend_type('float')  # []
      # @param backend_type [String] backend type of attributes
      # @return [Array<Fixnum>] contains attribute ids for passed backend type

      # @!method hydra_attribute_names_for_backend_type(backend_type)
      # Returns array of attribute names for passed backend type.
      #
      # @note If no attributes, returns blank array.
      # @example
      #   Product.hydra_attributes.create(name: 'one', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'two', backend_type: 'string')
      #   Product.hydra_attributes.create(name: 'three', backend_type: 'integer')
      #
      #   Product.hydra_attributes_for_backend_type('string') # ["one", "two"]
      #   Product.hydra_attributes_for_backend_type('float')  # []
      # @param backend_type [String] backend type of attributes
      # @return [Array<HydraAttribute::HydraAttribute>] contains attribute models for passed backend type
      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_attribute_#{prefix}s_for_backend_type(backend_type)
            values = hydra_attribute_#{prefix}s_by_backend_type[backend_type]
            values.nil? ? [] : values
          end
        EOS
      end

      # Clear cache for the following methods:
      # * hydra_attributes
      # * hydra_attribute(identifier)
      # * hydra_attribute_ids
      # * hydra_attribute_names
      # * hydra_attribute_backend_types
      # * hydra_attributes_by_backend_type
      # * hydra_attribute_ids_by_backend_type
      # * hydra_attribute_names_by_backend_type
      #
      # @note This method should not be called manually. It used for hydra_attribute gem engine.
      # @return [NilClass]
      def clear_hydra_attribute_cache!
        [
          :@hydra_attributes,
          :@hydra_attribute,
          :@hydra_attribute_ids,
          :@hydra_attribute_names,
          :@hydra_attribute_backend_types,
          :@hydra_attributes_by_backend_type,
          :@hydra_attribute_ids_by_backend_type,
          :@hydra_attribute_names_by_backend_type,
        ].each do |variable|
          remove_instance_variable(variable) if instance_variable_defined?(variable)
        end
      end
    end

    def hydra_attribute?(name)
      self.class.hydra_attribute_names.include?(name.to_s)
    end
  end
end