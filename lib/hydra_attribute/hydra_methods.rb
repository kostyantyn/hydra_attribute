module HydraAttribute

  # @see HydraAttribute::HydraMethods::ClassMethods ClassMethods for additional documentation
  module HydraMethods
    extend ActiveSupport::Concern
    extend Memoizable

    include HydraSetMethods
    include HydraAttributeMethods
    include HydraValueMethods

    included do
      alias_method_chain :write_attribute, :hydra_set_id
    end

    module ClassMethods
      extend Memoizable

      # Finds attribute for attribute sets. Returns all attributes if attribute set is undefined.
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'title', backend_type: 'string')
      #   hydra_set.hydra_attributes.create(name: 'color', backend_type: 'string')
      #
      #   Product.hydra_set_attributes('Default')
      #   # [<HydraAttribute::HydraAttribute name: "title">, <HydraAttribute::HydraAttribute name: "color">]
      #
      # @example attribute set doesn't exist
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'title', backend_type: 'string')
      #
      #   Product.hydra_set_attributes('FAKE')
      #   # [<HydraAttribute::HydraAttribute name: "name">, <HydraAttribute::HydraAttribute name: "title">]
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @return [ActiveRecord::Relation] contains preloaded attribute models
      def hydra_set_attributes(hydra_set_identifier)
        hydra_set = hydra_set(hydra_set_identifier)
        hydra_set.nil? ? hydra_attributes : hydra_set.hydra_attributes
      end

      # Returns backend types for attributes which are assigned to passed attribute set.
      # If attribute set doesn't exist, return all attribute backend types.
      #
      # @note This method is cacheable
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attribute_backend_types('Default')
      #   # ["float", "boolean"]
      #
      # @example attribute set doesn't exist
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attribute_backend_types('FAKE')
      #   # ["string", float", "boolean"]
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @return [Array<String>] contains unique list of attribute backend types
      def hydra_set_attribute_backend_types(hydra_set_identifier)
        hydra_set_attributes(hydra_set_identifier).map(&:backend_type).uniq
      end
      hydra_memoize :hydra_set_attribute_backend_types

      # @!method hydra_set_attribute_ids(hydra_set_identifier)
      # Returns ids for attributes which are assigned to passed attribute set.
      # If attribute set doesn't exist, return all attribute ids.
      #
      # @note This method is cacheable
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')      # 1
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')    # 2
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean') # 3
      #
      #   Product.hydra_set_attribute_ids('Default')
      #   # [2, 3]
      #
      # @example attribute set doesn't exist
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')      # 1
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')    # 2
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean') # 3
      #
      #   Product.hydra_set_attribute_ids('FAKE')
      #   # [1, 2, 3]
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @return [Array<Fixnum>] contains unique list of attribute ids

      # @!method hydra_set_attribute_names(hydra_set_identifier)
      # Returns names for attributes which are assigned to passed attribute set.
      # If attribute set doesn't exist, return all attribute names.
      #
      # @note This method is cacheable
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attribute_names('Default')
      #   # ["price", "active"]
      #
      # @example attribute set doesn't exist
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attribute_names('FAKE')
      #   # ["name", "price", "active"]
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @return [Array<String>] contains unique list of attribute names
      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s(hydra_set_identifier)
            hydra_set_attributes(hydra_set_identifier).map(&:#{prefix})
          end
          hydra_memoize :hydra_set_attribute_#{prefix}s
        EOS
      end

      # Groups attributes for attribute set by backend type.
      # If attribute set doesn't exist, group all attributes.
      #
      # @note This method is cacheable
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attributes_by_backend_type('Default')
      #   # {
      #   #    "float"=>[<HydraAttribute::HydraAttribute name: 'price'>],
      #   #    "boolean"=>[<HydraAttribute::HydraAttribute name: 'active'>]
      #   # }
      #
      # @example attribute set doesn't exist
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attributes_by_backend_type('FAKE')
      #   # {
      #   #    "string"=>[<HydraAttribute::HydraAttribute name: 'name'>],
      #   #    "float"=>[<HydraAttribute::HydraAttribute name: 'price'>],
      #   #    "boolean"=>[<HydraAttribute::HydraAttribute name: 'active'>]
      #   # }
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @return [Hash{String => Array<HydraAttribute::HydraAttribute>}] contains grouped attributes by their backend types
      def hydra_set_attributes_by_backend_type(hydra_set_identifier)
        hydra_set_attributes(hydra_set_identifier).group_by(&:backend_type)
      end
      hydra_memoize :hydra_set_attributes_by_backend_type

      # @!method hydra_set_attribute_ids_by_backend_type(hydra_set_identifier)
      # Groups attribute ids for attribute set by backend type.
      # If attribute set doesn't exist, group all attribute ids.
      #
      # @note This method is cacheable
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')      # 1
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')    # 2
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean') # 3
      #
      #   Product.hydra_set_attribute_ids_by_backend_type('Default')
      #   # {"float"=>[2], "boolean"=>[3]}
      #
      # @example attribute set doesn't exist
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')      # 1
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')    # 2
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean') # 3
      #
      #   Product.hydra_set_attribute_ids_by_backend_type('FAKE')
      #   # {"string"=>[1], "float"=>[2], "boolean"=>[3]}
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @return [Hash{String => Array<Fixnum>}] contains grouped attribute ids by their backend types

      # @!method hydra_set_attribute_names_by_backend_type(hydra_set_identifier)
      # Groups attribute names for attribute set by backend type.
      # If attribute set doesn't exist, group all attribute names.
      #
      # @note This method is cacheable
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attribute_names_by_backend_type('Default')
      #   # {"float"=>["price"], "boolean"=>["active"]}
      #
      # @example attribute set doesn't exist
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
      #   hydra_set.hydra_attributes.create(name: 'active', backend_type: 'boolean')
      #
      #   Product.hydra_set_attribute_names_by_backend_type('FAKE')
      #   # {"string"=>["name"], "float"=>["price"], "boolean"=>["active"]}
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @return [Hash{String => Array<String>}] contains grouped attribute names by their backend types
      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s_by_backend_type(hydra_set_identifier)
            hydra_set_attributes(hydra_set_identifier).each_with_object({}) do |hydra_attribute, object|
              object[hydra_attribute.backend_type] ||= []
              object[hydra_attribute.backend_type] << hydra_attribute.#{prefix}
            end
          end
          hydra_memoize :hydra_set_attribute_#{prefix}s_by_backend_type
        EOS
      end

      # Returns attributes for attribute set and backend type.
      # If attribute set doesn't exist, returns all attributes for backend type.
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string')
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')
      #
      #   Product.hydra_set_attributes_for_backend_type('Default', 'float')
      #   # [<HydraAttribute::HydraAttribute name: "price">]
      #
      # @example attribute set doesn't exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string')
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')
      #
      #   Product.hydra_set_attributes_for_backend_type('FAKE', 'string')
      #   # [<HydraAttribute::HydraAttribute name: "name">, <HydraAttribute::HydraAttribute name: "title">]
      #
      # @example attributes doesn't exist for backend type
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string')
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')
      #
      #   Product.hydra_set_attributes_for_backend_type('Default', 'boolean')
      #   # []
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @param backend_type [String] see HydraAttribute::SUPPORTED_BACKEND_TYPES
      # @return [Array] contains attribute models
      def hydra_set_attributes_for_backend_type(hydra_set_identifier, backend_type)
        hydra_attributes = hydra_set_attributes_by_backend_type(hydra_set_identifier)[backend_type]
        hydra_attributes.nil? ? [] : hydra_attributes
      end

      # @!method hydra_set_attribute_ids_for_backend_type(hydra_set_identifier, backend_type)
      # Returns attribute ids for attribute set and backend type.
      # If attribute set doesn't exist, returns all attribute ids for backend type.
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')     # 1
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string') # 2
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')  # 3
      #
      #   Product.hydra_set_attribute_ids_for_backend_type('Default', 'float')      # [2]
      #
      # @example attribute set doesn't exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')     # 1
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string') # 2
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')  # 3
      #
      #   Product.hydra_set_attribute_ids_for_backend_type('FAKE', 'string')        # [1, 2]
      #
      # @example attributes doesn't exist for backend type
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')     # 1
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string') # 2
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')  # 3
      #
      #   Product.hydra_set_attribute_ids_for_backend_type('Default', 'boolean')    # []
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @param backend_type [String] see HydraAttribute::SUPPORTED_BACKEND_TYPES
      # @return [Array<Fixnum>] contains attribute ids

      # @!method hydra_set_attribute_names_for_backend_type(hydra_set_identifier, backend_type)
      # Returns attribute names for attribute set and backend type.
      # If attribute set doesn't exist, returns all attribute names for backend type.
      #
      # @example attribute set exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string')
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')
      #
      #   Product.hydra_set_attribute_names_for_backend_type('Default', 'float') # ["price"]
      #
      # @example attribute set doesn't exists
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string')
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')
      #
      #   Product.hydra_set_attribute_names_for_backend_type('FAKE', 'string') # ["name", "title"]
      #
      # @example attributes doesn't exist for backend type
      #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
      #
      #   hydra_set = Product.hydra_sets.create(name: 'Default')
      #   hydra_sets.hydra_attributes.create(name: 'title', backend_type: 'string')
      #   hydra_sets.hydra_attributes.create(name: 'price', backend_type: 'float')
      #
      #   Product.hydra_set_attribute_names_for_backend_type('Default', 'boolean') # []
      #
      # @param hydra_set_identifier [Fixnum, String] id or name of attribute set
      # @param backend_type [String] see HydraAttribute::SUPPORTED_BACKEND_TYPES
      # @return [Array<String>] contains attribute names
      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_attribute_#{prefix}s_for_backend_type(hydra_set_identifier, backend_type)
            values = hydra_set_attribute_#{prefix}s_by_backend_type(hydra_set_identifier)[backend_type]
            values.nil? ? [] : values
          end
        EOS
      end

      # Clear cache for the following methods:
      # * hydra_set_attributes(hydra_set_identifier)
      # * hydra_set_attribute_ids(hydra_set_identifier)
      # * hydra_set_attribute_names(hydra_set_identifier)
      # * hydra_set_attribute_backend_types(hydra_set_identifier)
      # * hydra_set_attributes_by_backend_type(hydra_set_identifier)
      # * hydra_set_attribute_ids_by_backend_type(hydra_set_identifier)
      # * hydra_set_attribute_names_by_backend_type(hydra_set_identifier)
      #
      # Also calls the following methods:
      # * clear_hydra_set_cache!
      # * clear_hydra_attribute_cache!
      # * clear_hydra_value_cache!
      #
      # @note This method should not be called manually. It used for hydra_attribute gem engine.
      # @return [NilClass]
      def clear_hydra_method_cache!
        clear_hydra_set_cache!
        clear_hydra_attribute_cache!
        clear_hydra_value_cache!

        [
          :@hydra_set_attributes,
          :@hydra_set_attribute_ids,
          :@hydra_set_attribute_names,
          :@hydra_set_attribute_backend_types,
          :@hydra_set_attributes_by_backend_type,
          :@hydra_set_attribute_ids_by_backend_type,
          :@hydra_set_attribute_names_by_backend_type
        ].each do |variable|
          remove_instance_variable(variable) if instance_variable_defined?(variable)
        end
      end
    end

    # Returns hash with attribute names and values based on attribute set.
    #
    # @example
    #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
    #
    #   hydra_set = Product.hydra_sets.create(name: 'Default')
    #   hydra_set.hydra_attributes.create(name: 'title', backend_type: 'string')
    #   hydra_set.hydra_attributes.create(name: 'color', backend_type: 'string')
    #
    #   product = Product.new
    #   product.hydra_attributes # {"name"=>nil, "title"=>nil, "color"=>nil}
    #
    #   product.hydra_set_id = hydra_set.id
    #   product.hydra_attributes # {"title"=>nil, "color"=>nil}
    #
    # @return [Hash] contains attribute names and values
    def hydra_attributes
      hydra_value_models.inject({}) do |hydra_attributes, model|
        hydra_attributes[model.hydra_attribute_name] = model.value
        hydra_attributes
      end
    end

    # @!method hydra_attribute_ids
    # Returns attribute ids
    #
    # @example
    #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')    # 1
    #
    #   hydra_set = Product.hydra_sets.create(name: 'Default')
    #   hydra_set.hydra_attributes.create(name: 'title', backend_type: 'string') # 2
    #   hydra_set.hydra_attributes.create(name: 'color', backend_type: 'string') # 3
    #
    #   product = Product.new
    #   product.hydra_attribute_ids # [1, 2, 3]
    #
    #   product.hydra_set_id = hydra_set.id
    #   product.hydra_attribute_ids # [2, 3]
    #
    # @return [Array] contains attribute ids

    # @!method hydra_attribute_names
    # Returns attribute names
    #
    # @example
    #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
    #
    #   hydra_set = Product.hydra_sets.create(name: 'Default')
    #   hydra_set.hydra_attributes.create(name: 'title', backend_type: 'string')
    #   hydra_set.hydra_attributes.create(name: 'color', backend_type: 'string')
    #
    #   product = Product.new
    #   product.hydra_attribute_names # ["name", "title", "color"]
    #
    #   product.hydra_set_id = hydra_set.id
    #   product.hydra_attribute_names # ["title", "color"]
    #
    # @return [Array] contains attribute names

    # @!method hydra_attribute_backend_types
    # Returns attribute backend types
    #
    # @example
    #   Product.hydra_attributes.create(name: 'name', backend_type: 'string')
    #
    #   hydra_set = Product.hydra_sets.create(name: 'Default')
    #   hydra_set.hydra_attributes.create(name: 'price', backend_type: 'float')
    #   hydra_set.hydra_attributes.create(name: 'total', backend_type: 'integer')
    #
    #   product = Product.new
    #   product.hydra_attribute_backend_types # ["string", "float", "integer"]
    #
    #   product.hydra_set_id = hydra_set.id
    #   product.hydra_attribute_backend_types # ["float", "integer"]
    #
    # @return [Array] contains attribute backend types
    %w(ids names backend_types).each do |prefix|
      module_eval <<-EOS, __FILE__, __LINE__ + 1
        def hydra_attribute_#{prefix}
          self.class.hydra_set_attribute_#{prefix}(hydra_set_id)
        end
      EOS
    end

    # Finds attribute representation as a model by identifier
    #
    # @note This method is cacheable
    # @param identifier [Fixnum, String] id or name of attribute
    # @return [ActiveRecord::Base]
    def hydra_value_model(identifier)
      hydra_attribute = self.class.hydra_attribute(identifier)
      if hydra_attribute
        association = hydra_value_association(hydra_attribute.backend_type)
        association.find_model_or_build(hydra_attribute_id: hydra_attribute.id)
      end
    end
    hydra_memoize :hydra_value_model

    # Returns all attributes as models
    #
    # @note This method is cacheable
    # @return [Array] contains values models
    def hydra_value_models
      self.class.hydra_set_attribute_backend_types(hydra_set_id).inject([]) do |models, backend_type|
        models + hydra_value_association(backend_type).all_models
      end
    end
    hydra_memoize :hydra_value_models

    private
      # Resets locked attributes after setting new hydra_set_id
      def write_attribute_with_hydra_set_id(attr_name, value)
        if attr_name.to_s == 'hydra_set_id'
          self.class.hydra_attribute_backend_types.each do |backend_type|
            hydra_value_association(backend_type).clear_cache!
          end
          remove_instance_variable(:@hydra_value_models) if instance_variable_defined?(:@hydra_value_models)
        end
        write_attribute_without_hydra_set_id(attr_name, value)
      end
  end
end