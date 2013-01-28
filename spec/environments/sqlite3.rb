ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

RSpec.configure do |config|
  config.after do
    ActiveRecord::Base.connection_pool.connections.each do |connection|
      (connection.tables - %w[schema_migrations]).each do |table_name|
        connection.exec_query("DELETE FROM #{table_name}")
        connection.exec_query("DELETE FROM sqlite_sequence WHERE name='#{table_name}'")
      end
    end
  end
end