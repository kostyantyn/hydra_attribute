require 'active_record'
require 'hydra_attribute'
require 'database_cleaner'
require 'database_cleaner/cucumber'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.extend(HydraAttribute::ActiveRecord)

DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.start
end

After do |_|
  DatabaseCleaner.clean
end