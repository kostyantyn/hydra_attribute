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