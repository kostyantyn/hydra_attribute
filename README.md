# hydra_attribute

hydra_attribue allows to use EAV database structure for ActiveRecord models
and is compatibile with active_record >= 3.1. 

## Requirements
active_record >= 3.1

## Installation

Add this line to your application's Gemfile:
    
    gem 'hydra_attribute'

And then execute:
    
    $ bundle
    
After successful installation run rails generator:
    
    $ rails generate hydra_attribute:install
    
This command generates hydra_attribute initializer:
    
    HydraAttribute.setup do |config|
      # Add prefix for all attribute tables
      # config.table_prefix = 'hydra_'
      
      # Add prefix for has_many associations
      # config.association_prefix = 'hydra_'
      
      # Wrap all associated models in HydraAttribute module
      # config.use_module_for_associated_models = true
    end
    
And the last step is to generate db:migration:

    $ rails generate migration create_hydra_attrubute_tables
    
    # migration should look like this:
    class CreateHydraAttributeTables < ActiveRecord::Migration
      def up
        HydraAttribute::Migration.new(self).migrate
      end
      
      def down
        HydraAttribute::Migration.new(self).rollback
      end
    end

## Usage

Describe EAV attributes in models:
  
    # app/models/product.rb
    class Product < ActiveRecord::Base
    end
    
    # app/models/simple_product.rb
    class SimpleProduct < ActiveRecord::Base
      hydra_attributes do |hydra|
        hydra.string  :name, :code
        hydra.float   :price
        hydra.text    :description
        hydra.boolean :active
      end
    end
    
    # app/models/group_product.rb
    class GroupProduct < ActiveRecord::Base
      hydra_attributes do |hydra|
        hydra.string  :name
        hydra.float   :price
        hydra.integer :total
      end
    end
    
**hydra_attributes** helper generates EAV attributes with for current model.  
  
Supported attribute types:

    ::string, :text, :integer, :float, :datetime, :boolean

Now we can create products:

    $ rails c
    SimpleProduct.create(name: 'Book', code: '#1', price: 2.75, description: 'Some words...', active: true)
    =>
    GroupProduct.create(name: 'Furniture', price: 79.95, total: 2)
    =>
  

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
