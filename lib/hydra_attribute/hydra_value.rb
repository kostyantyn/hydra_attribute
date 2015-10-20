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

    include ::HydraAttribute::Model::IdentityMap
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty

    attr_reader :entity, :value

    define_attribute_method :value

    # Initialize hydra value object
    #
    # @param [ActiveRecord::Base] entity link to entity model
    # @param [Hash] attributes contain values of table row
    # @option attributes [Symbol] :id
    # @option attributes [Symbol] :hydra_attribute_id this field is required
    # @option attributes [Symbol] :value
    def initialize(entity, attributes = {})
      raise HydraAttributeIdIsMissedError unless attributes.has_key?(:hydra_attribute_id)
      @entity     = entity
      @attributes = attributes
      type_cast = column.respond_to?(:type_cast) ? :type_cast : :type_cast_from_database
      if attributes.has_key?(:value)
        @value = column.send(type_cast, attributes[:value])
      else
        @value = column.send(type_cast, column.default)
        attributes[:value] = column.default
      end
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

      # Returns database adapter
      #
      # @return [ActiveRecord::ConnectionAdapters::AbstractAdapter]
      def connection
        ::ActiveRecord::Base.connection
      end

      # Returns virtual value column
      #
      # @param [Fixnum] hydra_attribute_id
      # @return [ActiveRecord::ConnectionAdapters::Column]
      def column(hydra_attribute_id)
        nested_identity_map(:column).cache(hydra_attribute_id.to_i) do
          hydra_attribute = ::HydraAttribute::HydraAttribute.find(hydra_attribute_id)
          if ::ActiveRecord.version >= ::Gem::Version.new('4.2.0')
            backend_type = sql_type = hydra_attribute.backend_type
            backend_type = ::HydraAttribute::BACKEND_TYPE_MAP[backend_type.to_sym].new
            default_value = hydra_attribute.default_value
            default_value = backend_type.type_cast_from_database(default_value) if backend_type.respond_to? :type_cast_from_database
            ::ActiveRecord::ConnectionAdapters::Column.new(hydra_attribute.name, default_value, backend_type, sql_type)
          else
            ::ActiveRecord::ConnectionAdapters::Column.new(hydra_attribute.name, hydra_attribute.default_value, hydra_attribute.backend_type)
          end
        end
      end

      # Delete all values for current entity
      #
      # @param [HydraAttribute::HydraEntity] entity
      # @return [NilClass]
      def delete_entity_values(entity)
        hydra_attributes = ::HydraAttribute::HydraAttribute.all_by_entity_type(entity.class.name)
        hydra_attributes = hydra_attributes.group_by(&:backend_type)
        hydra_attributes.each do |backend_type, attributes|
          table = arel_tables[entity.class.table_name][backend_type]
          where = table['hydra_attribute_id'].in(attributes.map(&:id)).and(table['entity_id'].eq(entity.id))
          arel  = table.from(table)
          connection.delete(arel.where(where).compile_delete, 'SQL')
        end
      end
    end

    # Returns virtual value column
    #
    # @return [ActiveRecord::ConnectionAdapters::Column]
    def column
      self.class.column(@attributes[:hydra_attribute_id])
    end

    # Returns model ID
    #
    # @return [Fixnum]
    def id
      @attributes[:id]
    end

    # Sets new type casted attribute value
    #
    # @param [Object] new_value
    # @return [NilClass]
    def value=(new_value)
      value_will_change! unless value == new_value
      @attributes[:value] = new_value
      type_cast = column.respond_to?(:type_cast) ? :type_cast : :type_cast_from_database
      @value = column.send(type_cast, new_value)
    end

    # Returns not type cased value
    #
    # @return [Object]
    def value_before_type_cast
      @attributes[:value]
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
      @hydra_attribute ||= ::HydraAttribute::HydraAttribute.find(@attributes[:hydra_attribute_id])
    end

    # Checks if model is persisted
    #
    # @return [TrueClass, FalseClass]
    def persisted?
      @attributes[:id].present?
    end

    # Saves model
    # Performs +insert+ or +update+ sql query
    # Method doesn't perform sql query if model isn't modified
    #
    # @return [TrueClass, FalseClass]
    def save
      raise EntityModelIsNotPersistedError unless entity.persisted?

      if persisted?
        return false unless changed?
        update
      else
        create
      end

      @previously_changed = changes
      @changed_attributes.clear

      true
    end

    private
      # Creates arel insert manager
      #
      # @return [Arel::InsertManager]
      def arel_insert
        table  = self.class.arel_tables[entity.class.table_name][hydra_attribute.backend_type]
        fields = {}
        fields[table[:entity_id]]          = entity.id
        fields[table[:hydra_attribute_id]] = hydra_attribute.id
        fields[table[:value]]              = value
        fields[table[:created_at]]         = Time.now
        fields[table[:updated_at]]         = Time.now
        table.compile_insert(fields)
      end

      # Creates arel update manager
      #
      # @return [Arel::UpdateManager]
      def arel_update
        table = self.class.arel_tables[entity.class.table_name][hydra_attribute.backend_type]
        arel  = table.from(table)
        arel.where(table[:id].eq(id)).compile_update({table[:value] => value, table[:updated_at] => Time.now}, id)
      end

      # Performs sql insert query
      #
      # @return [Integer] primary key
      def create
        @attributes[:id] = self.class.connection.insert(arel_insert, 'SQL')
      end

      # Performs sql update query
      #
      # @return [NilClass]
      def update
        self.class.connection.update(arel_update, 'SQL')
      end
  end
end
