Given /^create connection$/ do
  spec        = ActiveRecord::Base::ConnectionSpecification.new({database: ':memory:', adapter: 'sqlite3'}, 'sqlite3_connection')
  @connection = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec).connection
end

Given /^(create|drop|migrate|rollback)(?:\sto|\sfrom)? hydra entity "([^"]+)"$/ do |method, table|
  HydraAttribute::Migrator.send(method, @connection, table)
end

Given /^create table "([^"]+)"$/ do |table|
  @connection.create_table(table)
end

Then /^should have the following (\d+) tables?:$/ do |count, table|
  @connection.should have(count.to_i).tables

  table.rows.flatten.each do |name|
    @connection.tables.should include(name)
  end
end

Then /^should not have any tables$/ do
  @connection.should have(0).tables
end

Then /^table "([^"]+)" should have the following (columns|indexes):$/ do |table_name, method, table|
  connection_params = @connection.send(method, table_name).sort_by(&:name)
  checked_params    = table.hashes.map { |hash| type_cast_hash(hash) }.sort_by { |param| param['name'] }

  unless connection_params.length == checked_params.length
    raise %Q(Table "#{table_name}" has "#{connection_params.length}" #{method} but in our test "#{checked_params.length}". Diff: is "#{connection_params.map(&:name)}" but should be "#{checked_params.map { |h| h['name'] }}")
  end

  connection_params.zip(checked_params).each do |(real_params, params)|
    params.keys.each do |name|
      params[name].should == real_params.send(name)
    end
  end
end

Then /^table "([^"]+)" should have (\d+) records?$/ do |table_name, count|
  result = ActiveRecord::Base.connection.select_one("SELECT COUNT(*) AS count FROM #{table_name}")
  result['count'].should == count.to_i
end

Then /^table "([^"]+)" should have (\d+) records?:$/ do |table_name, count, table|
  step %(table "#{table_name}" should have #{count} records)

  table.hashes.each do |hash|
    where  = hash.map { |name, value| %(#{name} = "#{type_cast_value(value)}") }.join(' AND ')
    result = ActiveRecord::Base.connection.select_one("SELECT COUNT(*) AS count FROM #{table_name} WHERE #{where}")
    result['count'].should >= 1
  end
end

