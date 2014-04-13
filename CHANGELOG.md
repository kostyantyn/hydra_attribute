**0.6.0 (...)**
* Support `ActiveRecord` 4 and remove supporting version 3
* Support associations between entities
  ```ruby
    class Category < ActiveRecord::Base
      include HydraAttribute::ActiveRecord
      has_many :products, dependent: :destroy
    end

    class Product < ActiveRecord::Base
      include HydraAttribute::ActiveRecord
      belongs_to :category
    end
  ```
* Validate hydra attribute name. It must include only word characters and entity class must not have corresponding method.

**0.5.1 (March 27, 2014)**
* Fix `HydraAttribute::Middleware::IdentityMap`. Clear all cached values after request.

**0.5.0 (February 16, 2014)**
* Cache all hydra attributes per request
* Replace `ActiveRecord` with plain database connection to fetch hydra attributes
* Add support of `decimal` backend type
* Add `id` to `hydra_attribute_sets` table
* Use new index name pattern `*_idx` instead of `*_index`

**0.4.2 (January 20, 2013)**
* Fixed bug in `count` method which added unnecessary columns to query [#2](https://github.com/kostyantyn/hydra_attribute/issues/2)

**0.4.1 (October 3, 2012)**
* Fixed bug which didn't allow to use hydra attributes for STI models

**0.4.0 (September 13, 2012)**
* Add attribute sets
* Add helper methods for attributes and attribute sets
* Remove `use_hydra_attributes` method from `ActiveRecord::Base`. Module `HydraAttribute::ActiveRecord` should be included instead

**0.3.2 (July 31, 2012)**
* Add `white_list` option which allows to add attribute to white list for entity during creation

**0.3.1 (July 28, 2012)**
* Fix bug "ActiveModel::MassAssignmentSecurity::Error: Can't mass-assign protected attributes: name, backend_type, default_value" during creation hydra attributes 

**0.3.0 (July 27, 2012)**
* All attributes are now stored in database
* Support default value for attributes
* `#inspect` method displays hydra attributes too

**0.2.0 (June 13, 2012)**
* Implement `group` method for `ActiveRecord::Relation` object 

**0.1.3 (June 11, 2012)**
* Fix bug when quoted column is passed to `ActiveRecord::Relation` method as a parameter

**0.1.2 (June 7, 2012)**
* Eval `define_hydra_attributes` block in Builder scope    
  
  ```ruby
    define_hydra_attributes do
      string :name
      float  :price
    end
  ```

**0.1.1 (June 6, 2012)**
* Update gem specification

**0.1.0 (June 6, 2012)** (initial release)
* Define EAV attributes
  
  ```ruby
    define_hydra_attributes do |hydra|
      hydra.string :name
      hydra.float  :price
    end
  ```

* Implement `where` method for `ActiveRecord::Relation` object
* Implement `order` method for `ActiveRecord::Relation` object
* Implement `reverse_order` method for `ActiveRecord::Relation` object
* Implement `select` method for `ActiveRecord::Relation` object
