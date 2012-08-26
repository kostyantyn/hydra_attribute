require 'active_record'
require 'hydra_attribute'
require 'database_cleaner'

ActiveSupport.on_load(:active_record) do
  self.default_timezone = :utc
  unless ActiveRecord::VERSION::STRING.start_with?('3.1.') # @COMPATIBILITY with 3.1.x. active_record 3.1 doesn't have "mass_assignment_sanitizer" method
    self.mass_assignment_sanitizer = :strict
  end

  ActiveRecord::Migration.send(:include, HydraAttribute::ActiveRecord::Migration)
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
DatabaseCleaner.strategy = :truncation

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

Before do
  redefine_hydra_entity('Product')
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end