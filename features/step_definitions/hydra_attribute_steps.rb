Given /^removed constants if they exist:$/ do |table|
  table.hashes.each do |hash|
    Object.send(:remove_const, hash[:name]) if Object.const_defined?(hash[:name])
  end
end

Given /^create model class "([^"]+)"$/ do |klass|
  Object.const_set(klass, Class.new(ActiveRecord::Base))
end

Given /^create model class "([^"]+)" as "([^"]+)" with hydra attributes:$/ do |klass, sti_class, table|
  Object.const_set klass, Class.new(Object.const_get(sti_class)) {
    hydra_attributes do |hydra|
      table.hashes.each do |hash|
        hydra.send(hash[:type], hash[:name].to_sym)
      end
    end
  }
end

Given /^create model "([^"]+)" with attributes "([^"]+)"$/ do |klass, attributes|
  attrs  = typecast_attributes(attributes.split)
  @model = Object.const_get(klass).create!(attrs)
end

Given /^create models:$/ do |table|
  table.hashes.each do |hash|
    attributes = Hash[hash[:attributes].split.map{ |attr| attr.split('=') }]
    Object.const_get(hash[:model]).create!(attributes)
  end
end

When /^load all "([^"]+)" records$/ do |klass|
  @records = Object.const_get(klass).all
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

Then /^it should have typecast attributes "([^"]+)"$/ do |attributes|
  @model.reload # ensure that all attributes have correct type
  typecast_attributes(attributes.split).each do |name, value|
    @model.send(name).should == value
  end
end

Then /^model "([^"]+)" should "(should|should_not)" to "([^"]+)"$/ do |klass, method, attributes|
  model = Object.const_get(klass).new
  attributes.split.each do |attribute|
    model.send(method, respond_to(attribute))
  end
end

Then /^class "([^"]+)"::"([^"]+)" "(should|should_not)" have "([^"]+)"$/ do |klass, method, behavior, params|
  klass = Object.const_get(klass)
  klass.send(method).send(behavior) =~ params.split.map(&:to_sym)
end