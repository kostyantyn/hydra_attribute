When /^filter "([^"]+)" by:$/ do |klass, table|
  condition = table.hashes.each_with_object({}) { |item, hash| hash[item[:field].to_sym] = type_cast_value(item[:value]) }
  @records  = Object.const_get(klass).where(condition)
end

When /^filter "([^"]+)" records by "([^"]+)"$/ do |klass, attribute|
  @records = Object.const_get(klass)
  step %(filter records by "#{attribute}")
end

When /^filter records by "([^"]+)"$/ do |attribute|
  name, value = type_cast_attribute(attribute)
  @records = @records.where(name => value)
end

When /^group "([^"]+)" by "([^"]+)"$/ do |klass, attributes|
  @records = Object.const_get(klass)
  step %(group by "#{attributes}")
end

When /^group by "([^"]+)"$/ do |attributes|
  @records = @records.group(attributes.split)
end

When /^(order|reorder) "([^"]+)" records by "([^"]+)"$/ do |sort_method, klass, attributes|
  @records = Object.const_get(klass)
  step %(#{sort_method} records by "#{attributes}")
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

When /^reverse order records$/ do
  @records = @records.reverse_order
end

When /^"([^"]+)" select only the following columns "([^"]+)"$/ do |klass, columns|
  @records = Object.const_get(klass).select(columns.split(/\s+/).map(&:to_sym))
end
