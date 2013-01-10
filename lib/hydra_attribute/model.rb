require 'hydra_attribute/model/identity_map'

module HydraAttribute
  module Model
    extend ActiveSupport::Concern

    included do
      include IdentityMap
    end

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
          def #{column_name}                    # def name
            attributes[:#{column_name}]         #   attributes[:name]
          end                                   # end

          def #{column_name}=(value)            # def name=(value)
            attributes[:#{column_name}] = value #   attributes[:name] = value
          end                                   # end
        EOS
      end

      # Returns database adapter
      #
      # @return [ActiveRecord::ConnectionAdapters::AbstractAdapter]
      def connection
        @connection ||= ::ActiveRecord::Base.connection
      end

      # Returns table name
      #
      # @return [String]
      def table_name
        @table_name ||= name.tableize
      end

      # Returns table columns
      #
      # @return [Array<ActiveRecord::ConnectionAdapters::Column>]
      def columns
        connection.schema_cache.columns[table_name]
      end

      # Returns column names
      #
      # @return [Array<String>]
      def column_names
        @column_names ||= columns.map(&:name)
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
        new(result) if result
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

      # Creates new record and returns its ID
      #
      # @param [Hash] attributes
      # @return [Integer] primary key
      def create(attributes = {})
        connection.insert(compile_insert(attributes), 'SQL')
      end

      # Updates record by ID
      #
      # @param [Integer] id
      # @param [Hash] attributes
      # @return [NilClass]
      def update(id, attributes = {})
        connection.update(compile_update(id, attributes), 'SQL')
      end

      private
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
          compile_select(id: id).compile_update(fields)
        end

        # Compiles data for +WHERE+ part
        #
        # @param [Hash] attributes
        # @return [Arel::Nodes::And, Arel::Nodes::Equality]
        def compile_where(attributes = {})
          attributes.map do |name, value|
            arel_table[name].eq(value)
          end.inject(:and)
        end

        # Builds +arel+ object for select query
        #
        # @return [Arel::SelectManager]
        def select_manager
          arel_table.from(arel_table)
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
      @attributes = attributes
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
      id.present?
    end

    # Saves model
    # If model is persisted, update it otherwise create it.
    #
    # @return [TrueClass]
    def save
      if persisted?
        self.class.update(id, attributes.except(:id))
      else
        self.id = self.class.create(attributes)
      end
      true
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