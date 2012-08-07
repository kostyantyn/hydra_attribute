Given /^create connection$/ do
  spec        = ActiveRecord::Base::ConnectionSpecification.new({database: ':memory:', adapter: 'sqlite3'}, 'sqlite3_connection')
  @connection = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec).connection
end

Given /^(create|drop|migrate|rollback) hydra entity "([^"]+)"$/ do |method, table|
  HydraAttribute::Migrator.send(method, @connection, table)
end

Then /^should have the following (\d+) tables:$/ do |count, table|
  @connection.should have(count.to_i).tables

  table.rows.flatten.each do |name|
    @connection.tables.should include(name)
  end
end

Then /^should not have any tables$/ do
  @connection.should have(0).tables
end

Then /^table "([^"]+)" should have the following (columns|indexes):$/ do |table_name, method, table|
  @connection.send(method, table_name).each do |field|
    column_params = table.hashes.find { |hash| field.name == type_cast_value(hash['name']) }
    column_params.each do |param, value|
      field.send(param).should == type_cast_value(value)
    end
  end
end

