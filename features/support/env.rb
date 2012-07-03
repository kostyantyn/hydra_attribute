require 'active_record'
require 'hydra_attribute'
require 'database_cleaner'
require 'database_cleaner/cucumber'


ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.extend(HydraAttribute::ActiveRecord)

DatabaseCleaner.strategy = :truncation

Before do
  if Object.const_defined?(:Product)
    HydraAttribute::SUPPORT_TYPES.each do |type|
      assoc_model = HydraAttribute::AssociationBuilder.new(Product, type).model_name
      HydraAttribute.send(:remove_const, assoc_model)
    end

    Object.send(:remove_const, :Product)
  end

  ActiveSupport::Dependencies::Reference.clear!
  DatabaseCleaner.start

  class Product < ActiveRecord::Base
    use_hydra_attributes
  end
end

After do
  DatabaseCleaner.clean
end