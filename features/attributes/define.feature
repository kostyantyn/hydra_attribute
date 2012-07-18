Feature: create hydra attributes
  When use_hydra_attributes was called in model class
  Then entity should respond to attributes which are saved in hydra_attributes table

  When new hydra attribute is created
  Then entity should respond to it

  Background: create hydra attributes
    Given create "HydraAttribute::HydraAttribute" models with attributes as "hashes":
      | entity_type | name  | backend_type |
      | Product     | code  | string       |
      | Product     | price | float        |

  Scenario Outline: models should respond to hydra attributes
    Then model "<model>" <action> respond to "<attributes>"

    Scenarios: model should respond to its own hydra attributes
      | model   | action | attributes             |
      | Product | should | code                   |
      | Product | should | code=                  |
      | Product | should | code?                  |
      | Product | should | code_before_type_cast  |
      | Product | should | code_changed?          |
      | Product | should | code_change            |
      | Product | should | code_will_change!      |
      | Product | should | code_was               |
      | Product | should | reset_code!            |
      | Product | should | price                  |
      | Product | should | price=                 |
      | Product | should | price?                 |
      | Product | should | price_before_type_cast |
      | Product | should | price_changed?         |
      | Product | should | price_change           |
      | Product | should | price_will_change!     |
      | Product | should | price_was              |
      | Product | should | reset_price!           |

  Scenario: create hydra attribute in runtime
    When create "HydraAttribute::HydraAttribute" model with attributes as "hashes":
      | entity_type | name  | backend_type |
      | Product     | title | string       |
    Then model "Product" should respond to "title"

  Scenario: destroy hydra attribute in runtime
    Given create "Product" model with attributes as "rows_hash":
      | price | 10 |
    When destroy all "HydraAttribute::HydraAttribute" model with attributes as "hashes":
      | entity_type | name  |
      | Product     | price |
    Then model "Product" should not respond to "price"
    And total "HydraAttribute::HydraProductFloatValue" records should be "0"
