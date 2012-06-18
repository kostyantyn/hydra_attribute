ActiveRecord::Schema.define do
  create_table "hydra_attribute_sets", :force => true do |t|
    t.integer "hydra_attribute_id", :null => false
    t.integer "hydra_set_id",       :null => false
  end

  add_index "hydra_attribute_sets", ["hydra_attribute_id", "hydra_set_id"], :name => "hydra_attribute_sets_composite_index", :unique => true

  create_table "hydra_attributes", :force => true do |t|
    t.string   "entity_type",   :limit => 32, :null => false
    t.string   "name",          :limit => 32, :null => false
    t.string   "backend_type",  :limit => 16, :null => false
    t.string   "default_value"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "hydra_attributes", ["entity_type", "name"], :name => "hydra_attributes_composite_index", :unique => true

  create_table "hydra_product_boolean_values", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.boolean  "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_product_boolean_values", ["entity_id", "hydra_attribute_id"], :name => "hydra_boolean_values_composite_index", :unique => true

  create_table "hydra_product_datetime_values", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.datetime "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_product_datetime_values", ["entity_id", "hydra_attribute_id"], :name => "hydra_datetime_values_composite_index", :unique => true

  create_table "hydra_product_float_values", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.float    "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_product_float_values", ["entity_id", "hydra_attribute_id"], :name => "hydra_float_values_composite_index", :unique => true

  create_table "hydra_product_integer_values", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.integer  "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_product_integer_values", ["entity_id", "hydra_attribute_id"], :name => "hydra_integer_values_composite_index", :unique => true

  create_table "hydra_product_string_values", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.string   "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_product_string_values", ["entity_id", "hydra_attribute_id"], :name => "hydra_string_values_composite_index", :unique => true

  create_table "hydra_product_text_values", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.text     "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_product_text_values", ["entity_id", "hydra_attribute_id"], :name => "hydra_text_values_composite_index", :unique => true

  create_table "hydra_sets", :force => true do |t|
    t.string   "entity_type", :limit => 32, :null => false
    t.string   "name",        :limit => 32, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "hydra_sets", ["entity_type", "name"], :name => "hydra_sets_composite_index", :unique => true

  create_table "products", :force => true do |t|
    t.integer "hydra_set_id"
    t.string  "name"
    t.float   "price"
  end
end