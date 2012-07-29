# hydra_attribute
[![Build Status](https://secure.travis-ci.org/kostyantyn/hydra_attribute.png)](http://travis-ci.org/kostyantyn/hydra_attribute)

hydra_attribute is an implementation of
[EAV pattern](http://en.wikipedia.org/wiki/Entity–attribute–value_model) for ActiveRecord models.

## Requirements
* ruby >= 1.9.2
* active_record >= 3.1

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

##### or if we have already the entity table
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

##### Create model
```shell
rails generate model Product type:string name:string --migration=false
rake db:migrate
```

and add `use_hydra_attributes` to Product class
```ruby
class Product < ActiveRecord::Base
  use_hydra_attributes
end
```

##### Create some hydra attributes from `rails console`
```ruby
Product.hydra_attributes.create(name: 'color', backend_type: 'string', default_value: 'green')
Product.hydra_attributes.create(name: 'title', backend_type: 'string')
Product.hydra_attributes.create(name: 'total', backend_type: 'integer', default_value: 1)
```

Creating method accepts the following options:
* **name**. The **required** parameter. Allowed any string.   
* **backend_type**. The **required** parameter. Allowed one of the following strings: `string`, `text`, `integer`, `float`, `boolean` and `datetime`.
* **default_value**. The **optional** parameter. Allowed any value. By default is `nil`.
* **white_list**. The **optional** parameter. Should be `true` or `flase`. By defauls is `false`. if pass `white_list: true` this attribute will be added to white list and will be allowed for mass-assignment. This parameter is in black list for creation by default so if you want to pass it, you have to pass the role `as: :admin` too.

  ```ruby
    Product.hydra_attributes.create({name: 'title', backend_type: 'string', white_list: true}, as: :admin)
  ```

##### Create several objects

```ruby
Product.create.attributes
# {"id"=>1, created_at"=>..., "updated_at"=>..., "color"=>"green", "title"=>nil, "total"=>1}
Product.create(color: 'red', title: 'toy').attributes
# {"id"=>1, "created_at"=>..., "updated_at"=>..., "color"=>"red", "title"=>"toy", "total"=>1}
Product.create(title: 'book', total: 2).attributes
# {"id"=>1, "created_at"=>..., "updated_at"=>..., "color"=>"green", "title"=>"book", "total"=>2} 
```

##### Add the new attribute in runtime
```ruby
Product.hydra_attributes.create(name: 'price', backend_type: 'float', default_value: 0.0)
Product.create(title: 'car', price: 2.50).attributes
# {"id"=>4, "created_at"=>..., "updated_at"=>..., "color"=>"green", "title"=>"car", "price"=>2.5, "total"=>1} 
```

##### Obtain data
```ruby
Product.where(color: 'red').map(&:attributes)
# [{"id"=>2, "created_at"=>..., "updated_at"=>..., "color"=>"red", "title"=>"toy", "price"=>0.0, "total"=>1}] 
Product.where(color: 'green', price: nil).map(&:attributes)
# [{"id"=>1, "created_at"=>..., "updated_at"=>..., "color"=>"green", "title"=>nil, "price"=>0.0, "total"=>1},  
#  {"id"=>3, "created_at"=>..., "updated_at"=>..., "color"=>"green", "title"=>"book", "price"=>0.0, "total"=>2}] 
```
**Notice**: the attribute `price` was added in runtime and records that were created before have not this attribute
so they matched this condition `where(price: nil)`

##### Order data
```ruby
Product.order(:color).first.attributes
# {"id"=>1, "created_at"=>..., "updated_at"=>..., "color"=>"green", "title"=>nil, "price"=>0.0, "total"=>1} 
Product.order(:color).reverse_order.first.attributes
# {"id"=>2, "created_at"=>..., "updated_at"=>..., "color"=>"red", "title"=>"toy", "price"=>0.0, "total"=>1}
```

##### Select concrete attributes
```ruby
Product.select([:color, :title]).map(&:attributes)
# [{"id"=>1, "color"=>"green", "title"=>nil}, {"id"=>2, "color"=>"red", "title"=>"toy"},  
#  {"id"=>3, "color"=>"green", "title"=>"book"}, {"id"=>4, "color"=>"green", "title"=>"car"}]
```
**Notice**: `id` attribute will be added if we want to select hydra attribute

##### Group by attribute
```ruby
Product.group(:color).count
# {"green"=>3, "red"=>1}
```

## Notice

The each new minor version doesn't guarantee back compatibility with previous one 
until the first major version will be released. 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
