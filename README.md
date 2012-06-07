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
    
After successful installation run rails generator:
```shell
rails generate hydra_attribute:install
```

This command generates hydra_attribute initializer:
```ruby    
HydraAttribute.setup do |config|
  # Add prefix for all attribute tables
  # config.table_prefix = 'hydra_'
      
  # Add prefix for has_many associations
  # config.association_prefix = 'hydra_'
      
  # Wrap all associated models in HydraAttribute module
  # config.use_module_for_associated_models = true
end
```

And the last step is to generate db:migration:
```shell
rails generate migration create_hydra_attrubute_tables
```    
Migration should look like this:
```ruby    
class CreateHydraAttributeTables < ActiveRecord::Migration
  def up
    HydraAttribute::Migration.new(self).migrate
  end
      
  def down
    HydraAttribute::Migration.new(self).rollback
  end
end
```
## Usage

##### Generate model
```shell
rails generate model Product type:string name:string
rails generate model SimpleProduct --migration=false --parent=Product
rake db:migrate
```

##### Describe EAV attributes
```ruby
class SimpleProduct < Product
  attr_accessible :name, :title, :code, :quantity, :price, :active, :description
  
  define_hydra_attributes do
    string  :title, :code
    integer :quantity
    float   :price
    boolean :active
    text    :description
  end
end
```

##### Create some products
```shell
SimpleProduct.create(name: 'Book', title: 'book', code: '100', quantity: 5, price: 2.75, active: true,  description: '...')
SimpleProduct.create(name: 'Book', title: 'book', code: '101', quantity: 5, price: 3.75, active: true,  description: '...')
SimpleProduct.create(name: 'Book', title: 'book', code: '102', quantity: 4, price: 4.50, active: false, description: '...')
SimpleProduct.create(name: 'Book', title: nil,    code: '103', quantity: 3, price: 4.50, active: true,  description: '...')
SimpleProduct.create(name: 'Book',                code: '104', quantity: 2, price: 5.00, active: true,  description: '...')
```

##### "where"
```shell
SimpleProduct.where(name: 'Book', quantity: 5, price: 2.75).first.attributes
=> {"id"=>1, "type"=>"SimpleProduct", "name"=>"Book", "created_at"=>Tue, 05 Jun 2012 23:13:21 UTC +00:00, "updated_at"=>Tue, 05 Jun 2012 23:13:21 UTC +00:00, "title"=>"book", "code"=>"100", "quantity"=>5, "price"=>2.75, "active"=>true, "description"=>"..."} 

SimpleProduct.where(title: 'book', active: false).first.attributes
=> {"id"=>3, "type"=>"SimpleProduct", "name"=>"Book", "created_at"=>Tue, 05 Jun 2012 23:13:50 UTC +00:00, "updated_at"=>Tue, 05 Jun 2012 23:13:50 UTC +00:00, "title"=>"book", "code"=>"102", "quantity"=>4, "price"=>4.5, "active"=>false, "description"=>"..."}

SimpleProduct.where(title: nil).first.attributes
=> {"id"=>4, "type"=>"SimpleProduct", "name"=>"Book", "created_at"=>Tue, 05 Jun 2012 23:13:50 UTC +00:00, "updated_at"=>Tue, 05 Jun 2012 23:13:50 UTC +00:00, "title"=>nil, "code"=>"103", "quantity"=>3, "price"=>4.5, "active"=>true, "description"=>"..."} 

SimpleProduct.where(title: nil).last.attributes
=> {"id"=>5, "type"=>"SimpleProduct", "name"=>"Book", "created_at"=>Tue, 05 Jun 2012 23:13:51 UTC +00:00, "updated_at"=>Tue, 05 Jun 2012 23:13:51 UTC +00:00, "title"=>nil, "code"=>"104", "quantity"=>2, "price"=>5.0, "active"=>true, "description"=>"..."}
```

##### "order" and "reverse_order"
```shell
SimpleProduct.order(:code).first.attributes
=> {"id"=>1, "type"=>"SimpleProduct", "name"=>"Book", "created_at"=>Tue, 05 Jun 2012 23:30:48 UTC +00:00, "updated_at"=>Tue, 05 Jun 2012 23:30:49 UTC +00:00, "title"=>"book", "code"=>"100", "quantity"=>5, "price"=>2.75, "active"=>true, "description"=>"..."} 

SimpleProduct.order(:code).reverse_order.first.attributes
=> {"id"=>5, "type"=>"SimpleProduct", "name"=>"Book", "created_at"=>Tue, 05 Jun 2012 23:30:51 UTC +00:00, "updated_at"=>Tue, 05 Jun 2012 23:30:51 UTC +00:00, "title"=>nil, "code"=>"104", "quantity"=>2, "price"=>5.0, "active"=>true, "description"=>"..."} 
```

##### "select"
```shell
SimpleProduct.select([:code, :price]).map(&:attributes)
=> [{"code"=>"100", "price"=>2.75}, {"code"=>"101", "price"=>3.75}, {"code"=>"102", "price"=>4.5}, {"code"=>"103", "price"=>4.5}, {"code"=>"104", "price"=>5.0}]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
