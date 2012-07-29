Feature: destroy hydra attributes
  When destroy hydra attribute
  Then model should not respond to this attribute any more
  And all values for this attribute should be removed

  Background: create hydra attributes
    Given create hydra attributes for "Product" as "hashes":
      | name  | backend_type |
      | price | float        |

  Scenario: destroy hydra attribute in runtime
    Given create "Product" model with attributes as "rows_hash":
      | price | 10 |
    When destroy all "HydraAttribute::HydraAttribute" models with attributes as "rows_hash":
      |name | price |
    Then model "Product" should not respond to "price"
    And total "HydraAttribute::HydraFloatProduct" records should be "0"