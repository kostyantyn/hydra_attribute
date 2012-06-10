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