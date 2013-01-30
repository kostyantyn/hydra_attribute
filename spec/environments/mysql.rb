config = {
  :adapter  => 'mysql2',
  :host     => ENV['DB_HOST']     || 'localhost',
  :database => ENV['DB_NAME']     || 'hydra_attribute_test',
  :username => ENV['DB_USERNAME'] || 'root',
  :password => ENV['DB_PASSWORD'],
  :encoding => 'utf8'
}

ActiveRecord::Base.establish_connection(config.merge(database: nil))
ActiveRecord::Base.connection.drop_database(config[:database])
ActiveRecord::Base.connection.create_database(config[:database], charset: 'utf8', collation: 'utf8_unicode_ci')
ActiveRecord::Base.establish_connection(config)

RSpec.configure do |spec|
  spec.after do
    ActiveRecord::Base.connection_pool.connections.each do |connection|
      connection.tables.each do |table_name|
        connection.execute("TRUNCATE TABLE `#{table_name}`")
      end
    end
  end
end