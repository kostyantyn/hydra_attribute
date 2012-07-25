module HydraAttribute
  class Migrator

    def initialize(migration)
      @migration = migration
    end

    class << self
      %w(create remove migrate rollback).each do |method|
        class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{method}(migration, *args, &block)
            new(migration).#{method}(*args, &block)
          end
        EOS
      end
    end

    def create(name, options = {}, &block)
      create_entity(name, options, &block)
      create_attribute unless attribute_exists?
      create_values(name)
    end

    def drop(name)
      drop_values(name)
      drop_attributes unless values_exists?
      drop_entity(name)
    end

    def migrate(name)
      create_attribute unless attribute_exists?
      create_values(name)
    end

    def rollback(name)
      drop_values(name)
      drop_attribute unless values_exists?
    end

    private

    def create_entity(name, options = {})
      create_table name, options do |t|
        yield t if block_given?
      end
    end

    def create_attribute
      create_table :hydra_attributes do |t|
        t.string :entity_type,  limit: 32, null: false
        t.string :name,         limit: 32, null: false
        t.string :backend_type, limit: 16, null: false
        t.string :default_value
        t.timestamps
      end
      add_index :hydra_attributes, [:entity_type, :name], unique: true, name: 'hydra_attributes_index'
    end

    def create_values(name)
      SUPPORT_TYPES.each do |type|
        table_name = value_table(name, type)
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
      drop_table(name)
    end

    def drop_attribute
      drop_table(:hydra_attributes)
    end

    def drop_values(name)
      SUPPORT_TYPES.each do |type|
        drop_table(value_table(name, type))
      end
    end

    def value_table(name, type)
      "hydra_#{type}_#{name}"
    end

    def attribute_exists?
      table_exists?(:hydra_attributes)
    end

    def values_exists?
      tables.any? do |table|
        SUPPORT_TYPES.any? do |type|
          table.start_with?("hydra_#{type}_")
        end
      end
    end

    def method_missing(symbol, *args, &block)
      @migration.send(symbol, *args, &block)
    end
  end
end