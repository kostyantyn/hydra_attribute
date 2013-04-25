module HydraAttribute
  class Migrator

    def initialize(migration)
      @migration = migration
    end

    class << self
      %w(create drop migrate rollback).each do |method|
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
      create_set       unless set_exists?
      create_values(name)
    end

    def drop(name)
      drop_values(name)
      unless values_exists?
        drop_set
        drop_attribute
      end
      drop_entity(name)
    end

    def migrate(name, options = {}, &block)
      migrate_entity(name, options, &block)
      create_attribute unless attribute_exists?
      create_set       unless set_exists?
      create_values(name)
    end

    def rollback(name)
      drop_values(name)
      unless values_exists?
        drop_attribute
        drop_set
      end
      rollback_entity(name)
    end

    private
      def create_entity(name, options = {})
        create_table name, options do |t|
          t.integer :hydra_set_id, null: true
          yield t if block_given?
        end
        add_index name, :hydra_set_id, unique: false, name: "#{name}_hydra_set_id_idx"
      end

      def migrate_entity(name, options = {})
        change_table name, options do |t|
          t.integer :hydra_set_id, null: true
        end
        add_index name, :hydra_set_id, unique: false, name: "#{name}_hydra_set_id_idx"
      end

      def create_attribute
        create_table :hydra_attributes do |t|
          t.string  :entity_type,  limit: 32, null: false
          t.string  :name,         limit: 32, null: false
          t.string  :backend_type, limit: 16, null: false
          t.string  :default_value
          t.boolean :white_list,              null: false, default: false
          t.timestamps
        end
        add_index :hydra_attributes, [:entity_type, :name], unique: true, name: 'hydra_attributes_idx'
      end

      def create_set
        create_table :hydra_sets do |t|
          t.string :entity_type,  limit: 32, null: false
          t.string :name,         limit: 32, null: false
          t.timestamps
        end
        add_index :hydra_sets, [:entity_type, :name], unique: true, name: 'hydra_sets_idx'

        create_table :hydra_attribute_sets do |t|
          t.integer :hydra_attribute_id, null: false
          t.integer :hydra_set_id,       null: false
          t.timestamps
        end
        add_index :hydra_attribute_sets, [:hydra_attribute_id, :hydra_set_id], unique: true, name: 'hydra_attribute_sets_idx'
      end

      def create_values(name)
        SUPPORTED_BACKEND_TYPES.each do |type|
          table_name = value_table(name, type)
          create_table table_name do |t|
            t.integer :entity_id,          null: false
            t.integer :hydra_attribute_id, null: false
            case type
            when 'decimal'
              t.send type, :value, precision: 10, scale: 4, null: true
            else
              t.send type, :value, null: true
            end
            t.timestamps
          end
          add_index table_name, [:entity_id, :hydra_attribute_id], unique: true, name: "#{table_name}_idx"
        end
      end

      def drop_entity(name)
        drop_table(name)
      end

      def rollback_entity(name)
        remove_column name, :hydra_set_id
      end

      def drop_attribute
        drop_table(:hydra_attributes)
      end

      def drop_set
        drop_table(:hydra_attribute_sets)
        drop_table(:hydra_sets)
      end

      def drop_values(name)
        SUPPORTED_BACKEND_TYPES.each do |type|
          drop_table(value_table(name, type))
        end
      end

      def value_table(name, type)
        "hydra_#{type}_#{name}"
      end

      def attribute_exists?
        table_exists?(:hydra_attributes)
      end

      def set_exists?
        table_exists?(:hydra_sets)
      end

      def values_exists?
        tables.any? do |table|
          SUPPORTED_BACKEND_TYPES.any? do |type|
            table.start_with?("hydra_#{type}_")
          end
        end
      end

      def method_missing(symbol, *args, &block)
        @migration.send(symbol, *args, &block)
      end
  end
end