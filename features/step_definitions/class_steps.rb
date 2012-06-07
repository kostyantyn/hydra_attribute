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
    define_hydra_attributes do
      table.hashes.each do |hash|
        send(hash[:type], hash[:name].to_sym)
      end
    end
  }
end

Then /^class "([^"]+)"::"([^"]+)" "(should|should_not)" have (string|symbol) "([^"]+)" in array$/ do |klass, method, behavior, type, params|
  klass  = Object.const_get(klass)
  params = params.split
  params.map!(&:to_sym) if type == 'symbol'
  klass.send(method).send(behavior) =~ params
end

Then /^class "([^"]+)"::"([^"]+)" "(should|should_not)" have "([^"]+)" hash$/ do |klass, method, behavior, params|
  klass = Object.const_get(klass)
  array = params.split.map{ |item| item.split('=').map(&:to_sym) }
  klass.send(method).send(behavior) == Hash[array].stringify_keys
end