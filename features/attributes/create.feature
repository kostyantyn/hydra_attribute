Feature: create hydra attributes
  When new hydra attribute is created
  Then entity should respond to it

  Background: create hydra attributes
    Given create "HydraAttribute::HydraAttribute" model with attributes as "hashes":
      | entity_type | name  | backend_type |
      | Product     | price | float        |

  Scenario: create hydra attribute in runtime
    # Important: when respond_to? is called the hydra attributes are being loaded for entity class
    Then model "Product" should respond to "price"
    Given create "HydraAttribute::HydraAttribute" model with attributes as "hashes":
      | entity_type | name  | backend_type |
      | Product     | title | string       |
    Then model "Product" should respond to "title"
