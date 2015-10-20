module HydraAttribute
  class RecordNotFound < ::ActiveRecord::RecordNotFound
  end

  module Model
    # @see HydraAttribute::Model::Persistence::ClassMethods ClassMethods for documentation
    module Persistence
      extend ActiveSupport::Concern

      module ClassMethods
        # Creates +Mutex+ object
        #
        # @return [Mutex]
        def attribute_methods_mutex
          @attribute_methods_mutex ||= Mutex.new
        end

        # Holds generated attribute methods status
        #
        # @return [TrueClass, FalseClass]
        def generated_attribute_methods?
          @generated_attribute_methods ||= false
        end

        # Define attribute methods based on column names
        #
        # @return [NilClass]
        def define_attribute_methods
          attribute_methods_mutex.synchronize do
            return if generated_attribute_methods?
            column_names.each do |column_name|
              define_attribute_method(column_name)
            end
            @generated_attribute_methods = true
          end
        end

        # Defines attribute getter and setter
        #
        # @param [String] column_name
        # @return [NilClass]
        def define_attribute_method(column_name)
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{column_name}                                                       # def name
              attributes[:#{column_name}]                                            #   attributes[:name]
            end                                                                      # end

            def #{column_name}=(value)                                               # def name=(value)
              attributes[:#{column_name}] = type_cast_value(:#{column_name}, value)  #   attributes[:name] = type_cast_value(:name, value)
            end                                                                      # end

            def #{column_name}?                                                      # name?
              attributes[:#{column_name}].present?                                   #  attributes[:name].present?
            end                                                                      # end
          EOS
        end

        # Returns database adapter
        #
        # @return [ActiveRecord::ConnectionAdapters::AbstractAdapter]
        def connection
          ::ActiveRecord::Base.connection
        end

        # Returns table name
        #
        # @return [String]
        def table_name
          @table_name ||= name.demodulize.tableize
        end

        # Returns table columns
        #
        # @return [Array<ActiveRecord::ConnectionAdapters::Column>]
        def columns
          @columns ||= connection.schema_cache.columns(table_name)
        end

        # Returns hash of column objects with their names as a keys
        # Keys are string
        #
        # @return [Hash]
        def columns_hash
          @columns_hash ||= connection.schema_cache.columns_hash(table_name)
        end

        # Returns hash of column objects with their names as a keys
        # Keys are symbols
        #
        # @return [Hash]
        def symbolized_columns_hash
          @symbolized_columns_hash ||= columns_hash.symbolize_keys
        end

        # Return column object
        #
        # @param [String]
        # @return [ActiveRecord::ConnectionAdapters::Column]
        def column(name)
          columns_hash[name]
        end

        # Returns column names
        #
        # @return [Array<String>]
        def column_names
          @column_names ||= columns.map(&:name)
        end

        # Holds attributes with default values
        #
        # @return [Hash]
        def attributes
          @attributes ||= columns.each_with_object({}) do |column, attributes|
            attributes[column.name.to_sym] = column.default
          end
        end

        # Returns arel table
        #
        # @return [Arel::Table]
        def arel_table
          @arel_table ||= Arel::Table.new(table_name, self)
        end

        # Finds all records
        #
        # @return [Array<HydraAttribute::Model>]
        def all
          where
        end

        # Finds one record by ID
        #
        # @param [Integer] id
        # @return [HydraAttribute::Model]
        def find(id)
          result = connection.select_one(compile_select({id: id}, Arel.star, 1))
          raise RecordNotFound, "Couldn't find #{name} with id=#{id}" unless result
          new(result)
        end

        # Finds records with where filter
        #
        # @param [Hash] attributes
        # @param [Array] fields
        # @param [NilClass, Integer] limit
        # @param [NilClass, Integer] offset
        # @return [Array<HydraAttribute::Model>]
        def where(attributes = {}, fields = Arel.star, limit = nil, offset = nil)
          connection.select_all(compile_select(attributes, fields, limit, offset)).map do |values|
            new(values)
          end
        end

        # Finds records with negative where filter
        #
        # @param [Hash] attributes
        # @param [Array] fields
        # @param [NilClass, Integer] limit
        # @param [NilClass, Integer] offset
        # @return [Array<HydraAttribute::Model>]
        def where_not(attributes = {}, fields = Arel.star, limit = nil, offset = nil)
          select = compile_select({}, fields, limit, offset)
          select.where(compile_where_not(attributes)) unless attributes.empty?
          connection.select_all(select).map do |values|
            new(values)
          end
        end

        # Creates new record
        #
        # @param [Hash] attributes
        # @return [HydraAttribute::Model]
        def create(attributes = {})
          model = new(attributes.except(:id, 'id'))
          model.save
          model
        end

        # Updates record by ID
        #
        # @param [Integer] id
        # @param [Hash] attributes
        # @return [HydraAttribute::Model]
        def update(id, attributes = {})
          model = find(id)
          model.assign_attributes(attributes.except(:id, 'id'))
          model.save
          model
        end

        # Destroys model by its ID
        #
        # @param [Integer] id
        # @return [TrueClass, FalseClass]
        def destroy(id)
          find(id).destroy
        end

        # Destroys all models
        #
        # @return [Hash] result for each deleted object
        def destroy_all
          all.map(&:id).each_with_object({}) do |model_id, result|
            result[model_id] = destroy(model_id)
          end
        end

        # Compiles attributes for performing +SELECT+ query
        #
        # @param [Hash] attributes
        # @param [Array] fields attributes which should be selected
        # @param [NilClass, Integer] limit
        # @param [NilClass, Integer] offset
        # @return [Arel::SelectManager]
        def compile_select(attributes = {}, fields = Arel.star, limit = nil, offset = nil)
          columns = Array(fields).map { |field| arel_table[field] }
          arel    = select_manager.project(columns).take(limit).skip(offset)
          arel.where(compile_where(attributes)) unless attributes.blank?
          arel
        end

        # Compiles attributes for performing +INSERT+ query
        #
        # @param [Hash] attributes
        # @return [Arel::InsertManager]
        def compile_insert(attributes = {})
          fields = attributes_to_columns(attributes)
          arel_table.compile_insert(fields)
        end

        # Compiles attributes for performing +UPDATE+ query
        #
        # @param [String] id
        # @param [Hash] attributes
        # @return [Arel::UpdateManager]
        def compile_update(id, attributes = {})
          fields = attributes_to_columns(attributes)
          compile_select(id: id).compile_update(fields, id)
        end

        # Compiles attributes for performing +DELETE+ query
        #
        # @param [Hash] attributes
        # @return [Arel::DeleteManager]
        def compile_delete(attributes = {})
          compile_select(attributes).compile_delete
        end

        # Builds +arel+ object for select query
        #
        # @return [Arel::SelectManager]
        def select_manager
          arel_table.from(arel_table)
        end

        private
          # Compiles data for +WHERE+ part
          #
          # @param [Hash] attributes
          # @return [Arel::Nodes::And, Arel::Nodes::Equality]
          def compile_where(attributes = {})
            attributes.map do |name, value|
              method = value.is_a?(Array) ? :in : :eq
              arel_table[name].send(method, value)
            end.inject(:and)
          end

          # Compiles negative data for +WHERE+ part
          #
          # @param [Hash] attributes
          # @return [Arel::Nodes::And, Arel::Nodes::Equality]
          def compile_where_not(attributes = {})
            attributes.map do |name, value|
              method = value.is_a?(Array) ? :not_in : :not_eq
              arel_table[name].send(method, value)
            end.inject(:and)
          end

          # Replaces attributes' keys to +arel+ columns
          #
          # @param [Hash] attributes
          # @return [Hash]
          def attributes_to_columns(attributes = {})
            attributes.each_with_object({}) do |(name, value), fields|
              fields[arel_table[name]] = value
            end
          end
      end

      # Model initializer
      #
      # @param [Hash] attributes
      def initialize(attributes = {})
        @destroyed  = false
        @attributes = self.class.attributes.clone

        assign_attributes(attributes)
      end

      # Assigns attributes
      #
      # @return [Hash] current attributes
      def assign_attributes(new_attributes = {})
        new_attributes.symbolize_keys.each do |name, value|
          @attributes[name] = type_cast_value(name, value)
        end
      end

      # Return all attributes
      #
      # @return [Hash]
      def attributes
        @attributes
      end

      # Checks if model is saved in database
      #
      # @return [TrueClass, FalseClass]
      def persisted?
        id.present? and not destroyed?
      end

      # Checks if model is destroyed
      #
      # @return [TrueClass, FalseClass]
      def destroyed?
        @destroyed
      end

      # Saves model
      # If model is persisted, update it otherwise create it.
      #
      # @return [TrueClass]
      def save
        return true  if destroyed?
        return false unless valid?

        self.class.connection.transaction do
          persisted? ? update : create
        end
      end

      # Destroys record from database
      # This method runs callbacks
      #
      # @return [TrueClass]
      def destroy
        self.class.connection.transaction do
          delete
        end
      end

      # Redefines base method because attribute methods define dynamically
      #
      # @param [Symbol] method
      # @param [FalseClass, TrueClass] include_private
      # @return [FalseClass, TrueClass]
      def respond_to?(method, include_private = false)
        self.class.define_attribute_methods unless self.class.generated_attribute_methods?
        super
      end

      private
        # Performs +INSERT+ query
        #
        # @return [Integer] primary key
        def create
          return id if persisted? or destroyed?
          columns = attributes.except(:id, :created_at, :updated_at).merge(created_at: Time.now, updated_at: Time.now)
          self.id = self.class.connection.insert(self.class.compile_insert(columns), 'SQL').to_i
        end

        # Performs +UPDATE+ query
        #
        # @return [TrueClass]
        def update
          return true unless persisted?
          columns = attributes.except(:id, :created_at, :updated_at).merge(updated_at: Time.now)
          self.class.connection.update(self.class.compile_update(id, columns), 'SQL')
          true
        end

        # Deletes record from database
        #
        # @return [TrueClass]
        def delete
          return true unless persisted?
          self.class.connection.delete(self.class.compile_delete(id: id), 'SQL')
          @destroyed = true
        end

        # Type casts value based on its database type
        #
        # @param [Symbol] name
        # @param [Object] value
        # @return [Object] type casted value
        def type_cast_value(name, value)
          column = self.class.symbolized_columns_hash[name]
          column.respond_to?(:type_cast) ? column.type_cast(value) : column.type_cast_from_database(value)
        end

        # Redefine method for auto generation attribute methods
        #
        # @param [Symbol] symbol
        # @params[Array] args
        # @yield
        # @return [Object]
        def method_missing(symbol, *args, &block)
          if self.class.generated_attribute_methods?
            super
          else
            self.class.define_attribute_methods
            if respond_to?(symbol)
              send(symbol, *args, &block)
            else
              super
            end
          end
        end

    end
  end
end
