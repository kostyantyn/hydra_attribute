Feature: destroy hydra set
  When destroy hydra set
  Then column hydra_set_id should be set to NULL for entity table

  Background: create hydra set and add hydra attributes to it
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | code  | integer      | [bool:t]   |
      | state | integer      | [bool:t]   |
      | title | string       | [bool:t]   |
    And create hydra set "Default" for "Product"
    And add "Product" hydra attributes to hydra set:
      | hydra attribute name | hydra set name  |
      | code                 | [array:Default] |
      | state                | [array:Default] |
    And create "Product" model with attributes as "rows_hash":
      | hydra_set_id | [eval:Product.hydra_sets.find_by_name('Default').id] |

  Scenario: after removing hydra set the hydra_set_id for entity should be NULL
    When destroy all "HydraAttribute::HydraSet" models with attributes as "rows_hash":
      | name | Default|
    Then table "products" should have 1 record:
      | hydra_set_id |
      | [nil:]       |
    And last created "Product" should have attribute "hydra_set_id" with value "[nil:]"

  Scenario: after removing hydra set entity should respond to all hydra attributes
    Given destroy all "HydraAttribute::HydraSet" models with attributes as "rows_hash":
      | name | Default|
    When find last "Product" model
    Then model attributes should match "[array:id,hydra_set_id,name,created_at,updated_at,code,state,title]"
