# This is a lightweight value model
# It acts as <tt>ActiveRecord::Base</tt> model and represents one record from <tt>hydra_value_*</tt> table
#
# Table schema:
# | id | entity_id | hydra_attribute_id | value | created_at | updated_at |
module HydraAttribute
  class HydraValue

    # This error is raised when +:hydra_attribute_id+ key isn't passed to initialize.
    # This key is important for determination the type of attribute which this model represents.
    class HydraAttributeIdIsMissedError < ArgumentError
      def initialize(msg = 'Key :hydra_attribute_id is missed')
        super
      end
    end

    # This error is raised when <tt>HydraAttribute::HydraValue</tt> model is saved
    # but <tt>entity model</tt> isn't persisted
    class EntityModelIsNotPersistedError < RuntimeError
      def initialize(msg = 'HydraValue model cannot be saved is entity model is not persisted')
        super
      end
    end

    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty

    attr_reader :entity, :attributes

    define_attribute_method :value

    # Initialize hydra value object
    #
    # @param [ActiveRecord::Base] entity link to entity model
    # @param [Hash] attributes contain values of table row
    # @option attributes [Symbol] :id
    # @option attributes [Symbol] :hydra_attribute_id this field is required
    # @option attributes [Symbol] :value
    def initialize(entity, attributes = {})
      @entity     = entity
      @attributes = attributes
      raise HydraAttributeIdIsMissedError unless attributes.has_key?(:hydra_attribute_id)
    end

    class << self
      # Holds <tt>Arel::Table</tt> objects grouped by entity table and backend type of attribute
      #
      # @return [Hash]
      def arel_tables
        @arel_tables ||= Hash.new do |entity_tables, entity_table|
          entity_tables[entity_table] = Hash.new do |backend_types, backend_type|
            backend_types[backend_type] = Arel::Table.new("hydra_#{backend_type}_#{entity_table}", ::ActiveRecord::Base)
          end
        end
      end
    end

    # Returns primary key
    #
    # @return [Integer]
    def id
      attributes[:id]
    end

    # Set primary key
    #
    # @return [Integer]
    def id=(id)
      attributes[:id] = id
    end

    # Returns hydra attribute ID
    #
    # @return [Integer]
    def hydra_attribute_id
      attributes[:hydra_attribute_id]
    end

    # Current type casted attribute value
    #
    # @return [Object]
    def value
      @value ||= column.default
    end

    # Sets new type casted attribute value
    #
    # @param [Object] new_value
    # @return [NilClass]
    def value=(new_value)
      value_will_change! unless value == new_value
      attributes[:value] = new_value
      @value = column.type_cast(new_value)
    end

    # Returns not type cased value
    #
    # @return [Object]
    def value_before_type_cast
      attributes[:value]
    end

    # Checks if value not blank and not zero for number types
    #
    # @return [TrueClass, FalseClass]
    def value?
      return false unless value

      if column.number?
        !value.zero?
      else
        value.present?
      end
    end

    # Returns hydra attribute model which contains meta information about attribute
    #
    # @return [HydraAttribute::HydraAttribute]
    def hydra_attribute
      entity.class.hydra_attribute(hydra_attribute_id)
    end

    # Returns attribute name
    #
    # @return [String]
    def name
      hydra_attribute.name
    end

    # Returns attribute backend type
    #
    # @return [String] one of the <tt>HydraAttribute::SUPPORTED_BACKEND_TYPES</tt> backend types
    def backend_type
      hydra_attribute.backend_type
    end

    # Checks if model is persisted
    #
    # @return [TrueClass, FalseClass]
    def persisted?
      id.present?
    end

    # Saves model
    # Performs +insert+ or +update+ sql query
    # Method doesn't perform sql query if model isn't modified
    #
    # @return [TrueClass]
    def save
      raise EntityModelIsNotPersistedError unless entity.persisted?

      if changed?
        persisted? ? update : create
      end

      @previously_changed = changes
      @changed_attributes.clear

      true
    end

    # Returns database connection adapter
    #
    # @return [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    def connection
      entity.connection
    end

    # Initializes virtual value column
    #
    # @return [ActiveRecord::ConnectionAdapters::Column]
    def column
      @column ||= ::ActiveRecord::ConnectionAdapters::Column.new(name, attributes[:value], backend_type)
    end

    private
      # Creates arel insert manager
      #
      # @return [Arel::InsertManager]
      def arel_insert
        table  = self.class.arel_tables[entity.class.table_name][backend_type]
        fields = {}
        fields[table[:entity_id]]          = entity.id
        fields[table[:hydra_attribute_id]] = hydra_attribute_id
        fields[table[:value]]              = value
        fields[table[:created_at]]         = Time.now.utc
        fields[table[:updated_at]]         = Time.now.utc
        table.compile_insert(fields)
      end

      # Creates arel update manager
      #
      # @return [Arel::UpdateManager]
      def arel_update
        table  = self.class.arel_tables[entity.class.table_name][backend_type]
        arel   = table.from(table)
        fields = {}
        fields[table[:value]]      = value
        fields[table[:updated_at]] = Time.now.utc
        arel.where(table[:id].eq(id)).compile_update(fields)
      end

      # Performs sql insert query
      #
      # @return [Integer] primary key
      def create
        self.id = connection.insert(arel_insert, 'SQL')
      end

      # Performs sql update query
      #
      # @return [NilClass]
      def update
        connection.update(arel_update, 'SQL')
      end
  end
end