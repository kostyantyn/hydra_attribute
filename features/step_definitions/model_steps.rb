Given /^create models:$/ do |table|
  table.hashes.each do |hash|
    attributes = typecast_attributes(hash[:attributes].split)
    Object.const_get(hash[:model]).create!(attributes)
  end
end

Given /^create model "([^"]+)" with attributes "([^"]+)"$/ do |klass, attributes|
  attrs  = typecast_attributes(attributes.split)
  @model = Object.const_get(klass).create!(attrs)
end

Then /^model "([^"]+)" should "(should|should_not)" to "([^"]+)"$/ do |klass, method, attributes|
  model = Object.const_get(klass).new
  attributes.split.each do |attribute|
    model.send(method, respond_to(attribute))
  end
end

Then /^it should have typecast attributes "([^"]+)"$/ do |attributes|
  @model.reload # ensure that all attributes have correct type
  typecast_attributes(attributes.split).each do |name, value|
    @model.send(name).should == value
  end
end