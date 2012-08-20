Given /^redefine "([^"]+)" class to use hydra attributes$/ do |klass|
  redefine_hydra_entity(klass)
end

Given /^create "([^"]+)" model$/ do |klass|
  klass.constantize.create!
end

Given /^build "([^"]+)" model$/ do |klass|
  @model = klass.constantize.new
end

Given /^build "([^"]+)" model:$/ do |klass, table|
  @model = klass.constantize.new(type_cast_hash(table.rows_hash))
end

When /^set "([^"]+)" to "([^"]+)"$/ do |attribute, value|
  @model.send("#{attribute}=", type_cast_value(value))
end

When /^(save|destroy) model$/ do |method|
  @model.send(method)
end

When /^find "([^"]+)" model by attribute "([^"])" and value "([^"]+)"$/ do |class_name, attribute, value|
  @model = class_name.constantize.send("find_by_#{attribute}", type_cast_value(value))
end

When /^find (first|last) "([^"]+)" model$/ do |method, class_name|
  @model = class_name.constantize.send(method)
end

When /^reload model$/ do
  @model.reload
end

Given /^create "([^"]+)" model with attributes as "([^"]+):"$/ do |klass, format, table|
  Array.wrap(table.send(format)).each do |hash|
    klass.constantize.create!(type_cast_hash(hash))
  end
end

Given /^create hydra attributes for "([^"]+)" with role "([^"]+)" as "([^"]+)":$/ do |klass, role, format, table|
  Array.wrap(table.send(format)).each do |hash|
    klass.constantize.hydra_attributes.create!(type_cast_hash(hash), as: role.to_sym)
  end
end

Given /^create hydra sets for "([^"]+)" as "([^"]+)":/ do |klass, format, table|
  Array.wrap(table.send(format)).each do |hash|
    klass.constantize.hydra_sets.create!(type_cast_hash(hash))
  end
end

Given /^add "([^"]+)" hydra attributes to hydra set:$/ do |klass, table|
  klass = klass.constantize

  Array.wrap(table.hashes).each do |hash|
    Array.wrap(type_cast_value(hash['hydra set name'])).each do |set|
      klass.hydra_sets.find_by_name(set).hydra_attributes << klass.hydra_attributes.find_by_name(type_cast_value(hash['hydra attribute name']))
    end
  end
end

Given /^(load and )?(save|create|update(?: all| attributes)?|destroy(?: all)?|delete(?: all)?)(?: for)? "([^"]+)" models? with attributes as "([^"]+)":$/ do |load, action, klass, format, table|
  action = action.gsub(' ', '_')
  klass  = klass.constantize
  models = load.present? ? klass.all : [klass]

  Array.wrap(table.send(format)).each do |hash|
    models.each do |model|
      model.send(action, type_cast_hash(hash))
    end
  end
end

Then /^model (should(?:\snot)?) respond to "([^"]+)"$/ do |method, attributes|
  method = method.gsub(/\s+/, '_')
  attributes.split.each do |attribute|
    @model.send(method, respond_to(attribute))
  end
end

Then /^model attributes (should(?:\snot)?) include "([^"]+)"$/ do |method, attributes|
  method = method.gsub(/\s+/, '_')
  attributes.split.each do |attribute|
    @model.attributes.keys.send(method, include(attribute))
  end
end

Then /^model "([^"]+)" (should(?:\snot)?) respond to "([^"]+)"$/ do |klass, method, attributes|
  @model = klass.constantize.new
  step %Q(model #{method} respond to "#{attributes}")
end

Then /^error "([^"]+)" (should(?:\snot)?) be risen when methods? "([^"]+)" (?:is|are) called$/ do |error_class, expect, methods|
  Array.wrap(methods.split).each do |method|
    lambda { @model.send(method) }.send(expect.gsub(/\s+/, '_'), raise_error(error_class.constantize))
  end
end

Then /^(last|first) created "([^"]+)" (should|should not) have the following attributes:$/ do |method, klass, match, table|
  table.rows_hash.each_with_object(klass.constantize.send(method)) do |(attribute, value), model|
    model.send(attribute).send(match) == type_cast_value(value)
  end
end

Then /^class "([^"]+)" (should(?:\snot)?) have "([^"]+)" in white list$/ do |klass, accept, attribute|
  method = accept.sub(' ', '_')
  klass.constantize.accessible_attributes.send(method, include(attribute))
end