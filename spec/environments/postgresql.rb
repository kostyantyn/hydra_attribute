config = {
  :adapter  => 'postgresql',
  :host     => ENV['DB_HOST']     || 'localhost',
  :database => ENV['DB_NAME']     || 'hydra_attribute_test',
  :username => ENV['DB_USERNAME'] || 'postgres',
  :password => ENV['DB_PASSWORD'],
  :encoding => 'utf8'
}

ActiveRecord::Base.establish_connection(config.merge(database: 'postgres', schema_search_path: 'public'))
ActiveRecord::Base.connection.drop_database(config[:database])
ActiveRecord::Base.connection.create_database(config[:database], config)
ActiveRecord::Base.establish_connection(config)

RSpec.configure do |spec|
  spec.after do
    ActiveRecord::Base.connection_pool.connections.each do |connection|
      connection.tables.each do |table_name|
        connection.execute("TRUNCATE #{table_name}")
      end
    end
  end
end