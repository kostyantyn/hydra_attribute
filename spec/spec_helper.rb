require 'hydra_attribute'

ActiveSupport.on_load(:active_record) do
  self.default_timezone          = :utc
  self.mass_assignment_sanitizer = :strict
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

Dir[File.expand_path('../fixtures/*.rb', __FILE__)].each do |file|
  load file
end

RSpec.configure do |config|
  config.before do
    Thread.current[:hydra_attribute] = nil
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