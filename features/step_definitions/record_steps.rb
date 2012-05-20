When /^load all "([^"]+)" records$/ do |klass|
  @records = Object.const_get(klass).all
end

When /^filter "([^"]+)" by:$/ do |klass, table|
  condition = table.hashes.each_with_object({}) { |item, hash| hash[item[:field].to_sym] = typecast_value(item[:value]) }
  @records  = Object.const_get(klass).where(condition)
end

Then /^should be selected "(\d+)" records:$/ do |length, table|
  @records.should have(length.to_i).items
  table.hashes.each do |hash|
    record = @records.detect { |r| r.send(hash[:field]) == typecast_value(hash[:value]) }
    record.should_not be_nil
  end
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