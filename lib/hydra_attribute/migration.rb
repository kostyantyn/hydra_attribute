module HydraAttribute
  class Migration
    def initialize(migration)
      @migration = migration
    end

    def migrate
      SUPPORT_TYPES.each do |type|
        table_name = HydraAttribute.config.table_name(type)
        @migration.create_table table_name do |t|
          t.integer :entity_id
          t.string  :entity_type
          t.string  :name
          t.send type, :value
        end

        @migration.add_index table_name, [:entity_id, :entity_type, :name], unique: true, name: "index_#{table_name}_on_attribute"
      end
    end

    def rollback
      SUPPORT_TYPES.each do |type|
        @migration.drop_table HydraAttribute.config.table_name(type)
      end
    end
  end
end