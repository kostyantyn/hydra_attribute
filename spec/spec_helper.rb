require 'active_record'
require 'hydra_attribute'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.extend(HydraAttribute::ActiveRecord)

require 'database_cleaner'
RSpec.configure do |config|
  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end