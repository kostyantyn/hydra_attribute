#Given /^create models:$/ do |table|
#  table.hashes.each do |hash|
#    attributes = typecast_attributes(hash[:attributes])
#    Object.const_get(hash[:model]).create!(attributes)
#  end
#end
#
#Given /^create model "([^"]+)" with attributes "([^"]+)"$/ do |klass, attributes|
#  attrs  = typecast_attributes(attributes)
#  @model = Object.const_get(klass).create!(attrs)
#end

Given /^create "([^"]+)" models with attributes:$/ do |klass, table|
  table.hashes.each do |hash|
    klass.constantize.create!(hash)
  end
end

Then /^model "([^"]+)" should "(should|should_not)" to "([^"]+)"$/ do |klass, method, attributes|
  model = Object.const_get(klass).new
  attributes.split.each do |attribute|
    model.send(method, respond_to(attribute))
  end
end

#Then /^it should have typecast attributes "([^"]+)"$/ do |attributes|
#  @model.reload # ensure that all attributes have correct type
#  typecast_attributes(attributes).each do |name, value|
#    @model.send(name).should == value
#  end
#end
#
#Then /^model "([^"]+)" should have only the following ((?:hydra )?attributes(?: before type cast)?) "([^"]+)"$/ do |klass, method, attributes|
#  model  = Object.const_get(klass).new
#  method = method.gsub(/\s+/, '_')
#  model.send(method).keys.should =~ attributes.split(/\s+/)
#end