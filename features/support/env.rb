require 'active_record'
require 'hydra_attribute'
require 'database_cleaner'
require 'database_cleaner/cucumber'


ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.extend(HydraAttribute::ActiveRecord)

DatabaseCleaner.strategy = :truncation

Before do
  %w(Product SimpleProduct GroupProduct).each do |const|
    if Object.const_defined?(const)
      klass = Object.const_get(const)
      HydraAttribute::SUPPORT_TYPES.each do |type|
        assoc_model = HydraAttribute::AssociationBuilder.new(klass, type).model_name
        HydraAttribute.send(:remove_const, assoc_model)
      end
      Object.send(:remove_const, const)
    end
  end
  ActiveSupport::Dependencies::Reference.clear!
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end