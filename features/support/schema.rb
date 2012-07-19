ActiveRecord::Schema.define do
  create_table "products", :force => true do |t|
    t.string  "name"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "hydra_attributes", :force => true do |t|
    t.string   "entity_type",   :limit => 32, :null => false
    t.string   "name",          :limit => 32, :null => false
    t.string   "backend_type",  :limit => 16, :null => false
    t.string   "default_value"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "hydra_attributes", ["entity_type", "name"], :name => "hydra_attributes_index", :unique => true

  create_table "hydra_boolean_products", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.boolean  "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_boolean_products", ["entity_id", "hydra_attribute_id"], :name => "hydra_boolean_products_index", :unique => true

  create_table "hydra_datetime_products", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.datetime "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_datetime_products", ["entity_id", "hydra_attribute_id"], :name => "hydra_datetime_products_index", :unique => true

  create_table "hydra_float_products", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.float    "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_float_products", ["entity_id", "hydra_attribute_id"], :name => "hydra_float_products_index", :unique => true

  create_table "hydra_integer_products", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.integer  "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_integer_products", ["entity_id", "hydra_attribute_id"], :name => "hydra_integer_products_index", :unique => true

  create_table "hydra_string_products", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.string   "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_string_products", ["entity_id", "hydra_attribute_id"], :name => "hydra_string_products_index", :unique => true

  create_table "hydra_text_products", :force => true do |t|
    t.integer  "entity_id",          :null => false
    t.integer  "hydra_attribute_id", :null => false
    t.text     "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hydra_text_products", ["entity_id", "hydra_attribute_id"], :name => "hydra_text_products_index", :unique => true
end