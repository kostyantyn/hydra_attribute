module HydraAttribute
  class Migration
    extend Forwardable
    def_delegators :@migration, :create_table, :drop_table, :add_index, :table_exists?, :tables

    def initialize(migration)
      @migration = migration
    end

    def create_entity(name, options = {})
      create_table name, options do |t|
        if block_given?
          yield t
        else
          t.timestamps
        end
      end

      create_attributes unless table_exists?(:hydra_attributes)

      SUPPORT_TYPES.each do |type|
        table_name = "hydra_#{type}_#{name}"
        create_table table_name do |t|
          t.integer :entity_id,          null: false
          t.integer :hydra_attribute_id, null: false
          t.send type, :value
          t.timestamps
        end
        add_index table_name, [:entity_id, :hydra_attribute_id], unique: true, name: "#{table_name}_index"
      end
    end

    def drop_entity(name)
      SUPPORT_TYPES.each do |type|
        drop_table "hydra_#{type}_#{name}"
      end

      drop_table :hydra_attributes if tables.one? { |table| table.start_with?('hydra_') }
      drop_table name
    end

    private

    def create_attributes
      create_table :hydra_attributes do |t|
        t.string :entity_type,  limit: 32, null: false
        t.string :name,         limit: 32, null: false
        t.string :backend_type, limit: 16, null: false
        t.string :default_value
        t.timestamps
      end
      add_index :hydra_attributes, [:entity_type, :name], unique: true, name: 'hydra_attributes_index'
    end
  end
end