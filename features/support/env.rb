require 'active_record'
require 'hydra_attribute'
require 'database_cleaner'
require 'database_cleaner/cucumber'

ActiveSupport.on_load(:active_record) do
  self.default_timezone = :utc
  unless ActiveRecord::VERSION::STRING.start_with?('3.1.')
    self.mass_assignment_sanitizer = :strict
  end
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
DatabaseCleaner.strategy = :truncation

Before do
  redefine_hydra_entity('Product')
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end