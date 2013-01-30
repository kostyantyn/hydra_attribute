ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

RSpec.configure do |spec|
  spec.after do
    ActiveRecord::Base.connection_pool.connections.each do |connection|
      connection.tables.each do |table_name|
        connection.execute("DELETE FROM #{table_name}")
        connection.execute("DELETE FROM sqlite_sequence WHERE name='#{table_name}'")
      end
    end
  end
end