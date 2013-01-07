require 'hydra_attribute/model/identity_map'

module HydraAttribute
  module Model
    extend ActiveSupport::Concern

    included do
      include IdentityMap

      attr_reader :attributes
    end

    module ClassMethods
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

    # Returns model ID
    #
    # @return [Integer, NilClass]
    def id
      attributes[:id]
    end

    # Sets model ID
    #
    # @param [Integer] new_id
    # @return [Integer]
    def id=(new_id)
      attributes[:id] = new_id
    end

    # Checks if model is saved in database
    #
    # @return [TrueClass, FalseClass]
    def persisted?
      id.present?
    end
  end
end