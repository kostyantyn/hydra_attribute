# hydra_attribute 

<a href="http://badge.fury.io/rb/hydra_attribute"><img src="https://badge.fury.io/rb/hydra_attribute@2x.png" alt="Gem Version" height="18"></a> [![Build Status](https://travis-ci.org/kostyantyn/hydra_attribute.svg)](https://travis-ci.org/kostyantyn/hydra_attribute) [![Coverage Status](https://coveralls.io/repos/kostyantyn/hydra_attribute/badge.png?branch=master)](https://coveralls.io/r/kostyantyn/hydra_attribute?branch=master) [![Code Climate](https://codeclimate.com/github/kostyantyn/hydra_attribute.png)](https://codeclimate.com/github/kostyantyn/hydra_attribute) [![Inline docs](http://inch-pages.github.io/github/kostyantyn/hydra_attribute.png)](http://inch-pages.github.io/github/kostyantyn/hydra_attribute)

[Demo](http://ec2-54-229-138-34.eu-west-1.compute.amazonaws.com) | [Wiki](https://github.com/kostyantyn/hydra_attribute/wiki) | [RDoc](http://rdoc.info/github/kostyantyn/hydra_attribute)

hydra_attribute is an implementation of
[EAV (Entity-Attribute-Value) pattern](http://en.wikipedia.org/wiki/Entity–attribute–value_model) for ActiveRecord models. It allows to create or remove attributes in runtime. Also each record may have different sets of attributes, for example: Product with ID 1 can have different set of attributes than Product with ID 2.

## Notice
Until the first major version is released:
* each new minor version doesn't guarantee back compatibility with previous one

## Requirements
* ruby >= 1.9.2
* active_record ~> 3.2

## Installation

Add the following line to Gemfile:
```ruby
gem 'hydra_attribute'
```
and run `bundle install` from your shell.
    
Then we should generate our migration:
```shell
rails generate migration create_hydra_attributes
```    
The content should be:
```ruby    
class CreateHydraAttributeTables < ActiveRecord::Migration
  def up
    create_hydra_entity :products do |t|
      # add here all other columns that should be in the entity table
      t.timestamps
    end
  end
      
  def down
    drop_hydra_entity :products
  end
end
```

**or if we have the entity table already**

```ruby    
class CreateHydraAttributeTables < ActiveRecord::Migration
  def up
    migrate_to_hydra_entity :products
  end
      
  def down
    rollback_from_hydra_entity :products
  end
end
```

## Usage

### Create model
```shell
rails generate model Product --migration=false
rake db:migrate
```

and include `HydraAttribute::ActiveRecord` to Product class
```ruby
class Product < ActiveRecord::Base
  include HydraAttribute::ActiveRecord
end
```

### Create hydra attributes
```ruby
Product.hydra_attributes.create(name: 'color', backend_type: 'string', default_value: 'green')
Product.hydra_attributes.create(name: 'title', backend_type: 'string')
Product.hydra_attributes.create(name: 'total', backend_type: 'integer', default_value: 1)
```

Creating method accepts the following options:
* **name**. The **required** parameter. Any string is allowed.   
* **backend_type**. The **required** parameter. One of the following strings is allowed: `string`, `text`, `integer`, `float`, `boolean` and `datetime`.
* **default_value**. The **optional** parameter. Any value is allowed. `nil` is default.
* **white_list**. The **optional** parameter. Should be `true` or `false`. `false` is default. If `white_list: true` is passed, this attribute will be added to white list and will be allowed for mass-assignment. This parameter is in black list for creation by default so if you want to pass it, you have to pass the role `as: :admin` too.

  ```ruby
    Product.hydra_attributes.create({name: 'title', backend_type: 'string', white_list: true}, as: :admin)
  ```

### Create records
```ruby
Product.create
#<Product id: 1, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "green", title: nil, total: 1>
Product.create(color: 'red', title: 'toy')
#<Product id: 2, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "red", title: "toy", total: 1>
Product.create(title: 'book', total: 2)
#<Product id: 3, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "green", title: "book", total: 2>
```

### Add new hydra attribute in runtime
```ruby
Product.hydra_attributes.create(name: 'price', backend_type: 'float', default_value: 0.0)
Product.create(title: 'car', price: 2.50)
#<Product id: 4, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "green", title: "car", total: 2, price: 2.5>
```

### Create hydra set
**Hydra set** allows to set the unique attribute list for each entity.

```ruby
hydra_set = Product.hydra_sets.create(name: 'Default')
hydra_set.hydra_attributes = Product.hydra_attributes.where(name: %w(color title price))

Product.create(color: 'black', title: 'ipod', price: 49.95, total: 5) do |product|
  product.hydra_set_id = hydra_set.id
end
#<Product id: 5, hydra_set_id: 1, created_at: ..., updated_at: ..., color: "black", title: "ipod", price: 49.95>
```
**Notice:** the `total` attribute has been skipped because it doesn't exist in hydra set.

### Obtain data
```ruby
Product.where(color: 'red')
# [#<Product id: 2, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "red", title: "toy", price: 0.0, total: 1>]
Product.where(color: 'green', price: nil)
# [
    #<Product id: 1, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "green", title: nil, price: 0.0, total: 1>,
    #<Product id: 3, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "green", title: "book", price: 0.0, total: 2>
# ]
```
**Notice**: the attribute `price` has been added in runtime. Records that had been created before this attribute don't have it therefore they satisfy the following condition: `where(price: nil)`

### Order data
```ruby
Product.order(:color, :title).first
#<Product id: 5, hydra_set_id: 1, created_at: ..., updated_at: ..., color: "black", title: "ipod", price: 49.95>
Product.order(:color, :title).reverse_order.first
#<Product id: 2, hydra_set_id: nil, created_at: ..., updated_at: ..., color: "red", title: "toy", price: 0.0, total: 1>
```

### Select concrete attributes
```ruby
Product.select([:color, :title])
# [
    #<Product id: 1, hydra_set_id: nil, color: "green", title: nil>,
    #<Product id: 2, hydra_set_id: nil, color: "red", title: "toy">,
    #<Product id: 3, hydra_set_id: nil, color: "green", title: "book">,
    #<Product id: 4, hydra_set_id: nil, color: "green", title: "car">,
    #<Product id: 5, hydra_set_id: 1, color: "black", title: "ipod">
# ] 
```
**Notice:** `id` and `hydra_set_id` attributes are forcibly added because they are important for correct work.

### Group by attribute
```ruby
Product.group(:color).count
# {"black"=>1, "green"=>3, "red"=>1}
```

## Wiki Docs
* [Create migration](https://github.com/kostyantyn/hydra_attribute/wiki/Create-migration)
* [Create attributes in runtime](https://github.com/kostyantyn/hydra_attribute/wiki/Create-attributes-in-runtime)
* [Create sets of attributes](https://github.com/kostyantyn/hydra_attribute/wiki/Create-sets-of-attributes)
* [Query methods](https://github.com/kostyantyn/hydra_attribute/wiki/Query-methods)
* [Database schema](https://github.com/kostyantyn/hydra_attribute/wiki/Database-schema)
* [Helper methods](https://github.com/kostyantyn/hydra_attribute/wiki/Helper-methods)
* [Migrate from 0.3.2 to 0.4.0](https://github.com/kostyantyn/hydra_attribute/wiki/Migrate-from-0.3.2-to-0.4.0) 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
