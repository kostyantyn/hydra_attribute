When /^load all "([^"]+)" records$/ do |klass|
  @records = Object.const_get(klass).all
end

When /^select "(first|last)" "([^"]+)" record$/ do |method, klass|
  @record = Object.const_get(klass).send(method)
end

When /^filter "([^"]+)" by:$/ do |klass, table|
  condition = table.hashes.each_with_object({}) { |item, hash| hash[item[:field].to_sym] = typecast_value(item[:value]) }
  @records  = Object.const_get(klass).where(condition)
end

When /^filter "([^"]+)" records by "([^"]+)"$/ do |klass, attribute|
  @records = Object.const_get(klass)
  step %Q(filter records by "#{attribute}")
end

When /^filter records by "([^"]+)"$/ do |attribute|
  name, value = typecast_attribute(attribute)
  @records = @records.where(name => value)
end

When /^(order|reorder) "([^"]+)" records by "([^"]+)"$/ do |sort_method, klass, attributes|
  @records = Object.const_get(klass)
  step %Q(#{sort_method} records by "#{attributes}")
end

When /^(order|reorder) records by "([^"]+)"$/ do |sort_method, attributes|
  reverse  = false
  fields   = attributes.split.inject([]) do |items, attribute|
    name, direction = attribute.split('=')
    reverse = true if direction == 'desc'
    items << name.to_sym
  end

  @records = @records.send(sort_method, fields)
  @records = @records.reverse_order if reverse
end

Then /^record should have the following ((?:hydra )?attributes(?: before type cast)?) "([^"]+)" in attribute hash$/ do |method, attributes|
  method = method.gsub(/\s+/, '_')
  typecast_attributes(attributes).each do |(name, value)|
    @record.send(method)[name.to_s].should == value
  end
end

Then /^record (read attribute(?: before type cast)?) "([^"]+)" and value should be "([^"]+)"$/ do |method, attribute, value|
  method = method.gsub(/\s+/, '_')
  @record.send(method, attribute).should == typecast_value(value)
end

Then /^"(first|last)" record should have "([^"]+)"$/ do |method, attribute|
  name, value = typecast_attribute(attribute)
  @records.send(method).send(name).should == value
end

Then /^records should have the following attributes:$/ do |table|
  table.hashes.each do |hash|
    record = @records.detect { |r| r.send(hash[:field]) == typecast_value(hash[:value]) }
    record.should_not be_nil
  end
end

Then /^total records should be "([^"]+)"$/ do |count|
  @records.should have(count.to_i).items
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