Given /^create connection$/ do
  spec        = ActiveRecord::Base::ConnectionSpecification.new({database: ':memory:', adapter: 'sqlite3'}, 'sqlite3_connection')
  @connection = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec).connection
end

Given /^(create|drop|migrate|rollback) hydra entity "([^"]+)"$/ do |method, table|
  HydraAttribute::Migrator.send(method, @connection, table)
end

Then /^should have the following (\d+) tables:$/ do |count, table|
  @connection.tables.count.should be(count.to_i)

  table.rows.flatten.each do |name|
    @connection.tables.should include(name)
  end
end

Then /^table "([^"]+)" should have the following columns:$/ do |table_name, table|
  @connection.columns(table_name).each do |column|
    column_params = table.hashes.find { |hash| column.name == type_cast_value(hash['name']) }
    column_params.each do |param, value|
      column.send(param).should == type_cast_value(value)
    end
  end
end

