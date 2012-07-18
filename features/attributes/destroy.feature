Feature: destroy hydra attributes
  When destroy hydra attribute
  Then model should not respond to this attribute any more
  And all values for this attribute should be removed

  Background: create hydra attributes
    Given create "HydraAttribute::HydraAttribute" models with attributes as "hashes":
      | entity_type | name  | backend_type |
      | Product     | price | float        |

  Scenario: destroy hydra attribute in runtime
    Given create "Product" model with attributes as "rows_hash":
      | price | 10 |
    When destroy all "HydraAttribute::HydraAttribute" model with attributes as "hashes":
      | entity_type | name  |
      | Product     | price |
    Then model "Product" should not respond to "price"
    And total "HydraAttribute::HydraProductFloatValue" records should be "0"