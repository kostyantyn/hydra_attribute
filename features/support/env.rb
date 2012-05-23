require 'active_record'
require 'hydra_attribute'
require 'database_cleaner'
require 'database_cleaner/cucumber'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.extend(HydraAttribute::ActiveRecord)

DatabaseCleaner.strategy = :truncation

Before do
  HydraAttribute::SUPPORT_TYPES.each do |type|
    const = HydraAttribute.config.associated_const_name(type)
    HydraAttribute.send(:remove_const, const) if HydraAttribute.const_defined?(const)
  end
  ActiveSupport::Dependencies::Reference.clear!
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end