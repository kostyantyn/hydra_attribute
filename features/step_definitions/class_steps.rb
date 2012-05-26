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
    define_hydra_attributes do |hydra|
      table.hashes.each do |hash|
        hydra.send(hash[:type], hash[:name].to_sym)
      end
    end
  }
end

Then /^class "([^"]+)"::"([^"]+)" "(should|should_not)" have "([^"]+)" array$/ do |klass, method, behavior, params|
  klass = Object.const_get(klass)
  klass.send(method).send(behavior) =~ params.split.map(&:to_sym)
end

Then /^class "([^"]+)"::"([^"]+)" "(should|should_not)" have "([^"]+)" hash$/ do |klass, method, behavior, params|
  klass = Object.const_get(klass)
  array = params.split.map{ |item| item.split('=').map(&:to_sym) }
  klass.send(method).send(behavior) == Hash[array]
end