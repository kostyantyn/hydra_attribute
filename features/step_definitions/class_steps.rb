#Then /^class "([^"]+)"::"([^"]+)" "(should|should_not)" have (string|symbol) "([^"]+)" in array$/ do |klass, method, behavior, type, params|
#  klass  = Object.const_get(klass)
#  params = params.split
#  params.map!(&:to_sym) if type == 'symbol'
#  klass.send(method).send(behavior) =~ params
#end
#
#Then /^class "([^"]+)"::"([^"]+)" "(should|should_not)" have "([^"]+)" hash$/ do |klass, method, behavior, params|
#  klass = Object.const_get(klass)
#  array = params.split.map{ |item| item.split('=').map(&:to_sym) }
#  klass.send(method).send(behavior) == Hash[array].stringify_keys
#end