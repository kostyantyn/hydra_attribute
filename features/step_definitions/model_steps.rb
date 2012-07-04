Given /^create "([^"]+)" model$/ do |klass|
  klass.constantize.create!
end

Given /^(create|destroy all) "([^"]+)" models? with attributes as "([^"]+)":$/ do |action, klass, format, table|
  action = action.gsub(' ', '_')
  Array.wrap(table.send(format)).each do |hash|
    klass.constantize.send(action, type_cast_hash(hash))
  end
end

Then /^model "([^"]+)" (should(?:\snot)?) respond to "([^"]+)"$/ do |klass, method, attributes|
  model  = klass.constantize.new
  method = method.gsub(/\s+/, '_')
  attributes.split.each do |attribute|
    model.send(method, respond_to(attribute))
  end
end

Then /^(last|first) created "([^"]+)" (should|should not) have the following attributes:$/ do |method, klass, match, table|
  table.rows_hash.each_with_object(klass.constantize.send(method)) do |(attribute, value), model|
    model.send(attribute).send(match) == type_cast_value(value)
  end
end