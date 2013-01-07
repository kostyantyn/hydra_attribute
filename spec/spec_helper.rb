require 'active_record'
require 'hydra_attribute'

ActiveSupport.on_load(:active_record) do
  self.default_timezone = :utc
  unless ActiveRecord::VERSION::STRING.start_with?('3.1.') # @COMPATIBILITY with 3.1.x. active_record 3.1 doesn't have "mass_assignment_sanitizer" method
    self.mass_assignment_sanitizer = :strict
  end

  ActiveRecord::Migration.send(:include, HydraAttribute::ActiveRecord::Migration)
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

class Migration < ActiveRecord::Migration
  def up
    create_hydra_entity :products do |t|
      t.string :name
      t.timestamps
    end
  end

  def down
  end
end

Migration.new.up

def redefine_hydra_entity(klass)
  ::ActiveSupport::Dependencies.clear

  Object.send(:remove_const, klass.to_sym) if Object.const_defined?(klass.to_sym)

  ::HydraAttribute::SUPPORTED_BACKEND_TYPES.each do |type|
    class_name = "Hydra#{type.capitalize}#{klass}".to_sym
    ::HydraAttribute.send(:remove_const, class_name) if ::HydraAttribute.const_defined?(class_name)
  end

  Object.const_set(klass.to_sym, Class.new(::ActiveRecord::Base))
  klass.to_s.constantize.send(:accessible_attributes_configs).values.each(&:clear)
  klass.to_s.constantize.attr_accessible :name, :hydra_set_id
  klass.to_s.constantize.send(:include, ::HydraAttribute::ActiveRecord)
end

RSpec.configure do |config|
  config.before do
    redefine_hydra_entity('Product')
  end

  config.after do
    ActiveRecord::Base.connection_pool.connections.each do |connection|
      (connection.tables - %w[schema_migrations]).each do |table_name|
        connection.exec_query("DELETE FROM #{table_name}")
        connection.exec_query("DELETE FROM sqlite_sequence WHERE name='#{table_name}'") # SQLite
      end
    end
  end
end