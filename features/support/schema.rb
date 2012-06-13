ActiveRecord::Schema.define do
  create_table "products", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "info"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hydra_string_values", :force => true do |t|
    t.integer "entity_id"
    t.string  "entity_type"
    t.string  "name"
    t.string  "value"
  end

  create_table "hydra_float_values", :force => true do |t|
    t.integer "entity_id"
    t.string  "entity_type"
    t.string  "name"
    t.float   "value"
  end

  create_table "hydra_boolean_values", :force => true do |t|
    t.integer "entity_id"
    t.string  "entity_type"
    t.string  "name"
    t.boolean "value"
  end

  create_table "hydra_integer_values", :force => true do |t|
    t.integer "entity_id"
    t.string  "entity_type"
    t.string  "name"
    t.integer "value"
  end

  create_table "hydra_text_values", :force => true do |t|
    t.integer "entity_id"
    t.string  "entity_type"
    t.string  "name"
    t.text    "value"
  end

  create_table "hydra_datetime_values", :force => true do |t|
    t.integer  "entity_id"
    t.string   "entity_type"
    t.string   "name"
    t.datetime "value"
  end
end