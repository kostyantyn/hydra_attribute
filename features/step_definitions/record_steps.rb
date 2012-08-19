When /^load all "([^"]+)" records$/ do |klass|
  @records = klass.constantize.all
end

When /^select (first|last) "([^"]+)" record$/ do |method, klass|
  @record = klass.constantize.send(method)
end

When /^assign attributes as "([^"]+)":$/ do |format, table|
  Array.wrap(table.send(format)).each do |hash|
    @record.assign_attributes(type_cast_hash(hash))
  end
end

When /^(save|destroy) record$/ do |action|
  @record.send(action)
end

When /^keep "([^"]+)" attribute$/ do |attribute|
  @keep ||= {}
  @keep[attribute] = @record.send(attribute)
end

Then /^update attributes as "([^"]+)":$/ do |role, table|
  @record.update_attributes(type_cast_hash(table.rows_hash), as: role.to_sym)
end

Then /^record should be nil$/ do
  @record.should be_nil
end

Then /^attribute "([^"]+)" (should(?:\snot)?) be the same$/ do |attribute, behavior|
  method = behavior.sub(/\s/, '_')
  @keep[attribute].send(method) == @record.send(attribute)
end

Then /^record (read attribute(?: before type cast)?) "([^"]+)" and value should be "([^"]+)"$/ do |method, attribute, value|
  method = method.gsub(/\s+/, '_')
  @record.send(method, attribute).should == type_cast_value(value)
end

Then /^"(first|last)" record should have "([^"]+)"$/ do |method, attribute|
  type_cast_attributes(attribute).each do |(name, value)|
    @records.send(method).send(name).should == value
  end
end

Then /^records should have the following attributes:$/ do |table|
  table.hashes.each do |hash|
    record = @records.detect { |r| r.send(hash[:field]) == type_cast_value(hash[:value]) }
    record.should_not be_nil
  end
end

Then /^records should have only the following "([^"]+)" names$/ do |attributes|
  @records.each do |record|
    record.attributes.keys.should =~ attributes.split(/\s+/)
  end
end

Then /^records should raise "([^"]+)" when call the following "([^"]+)"$/ do |error_class, methods|
  @records.each do |record|
    methods.split(/\s+/).each do |method|
      lambda { record.send(method) }.should raise_error(error_class.constantize)
    end
  end
end

Then /^total records should be "([^"]+)"$/ do |count|
  @records.to_a.should have(count.to_i).records
end

Then /^total "([^"]+)" records should be "([^"]+)"$/ do |klass, count|
  @records = klass.constantize.scoped
  step %Q(total records should be "#{count}")
end

Then /^records "(should|should_not)" have loaded associations:$/ do |should, table|
  table.hashes.each do |hash|
    @records.each do |record|
      record.association(hash[:association].to_sym).send(should, be_loaded)
    end
  end
end

Then /^"([^"]+)" records "(should|should_not)" have loaded associations:$/ do |klass, should, table|
  table.hashes.each do |hash|
    records = @records.select { |record| record.class.name == klass }
    records.each do |record|
      record.association(hash[:association].to_sym).send(should, be_loaded)
    end
  end
end