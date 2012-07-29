Feature: define hydra attributes
  When use_hydra_attributes was called in model class
  Then entity should respond to attributes which are saved in hydra_attributes table

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name           | backend_type    |
      | [string:code]  | [string:string] |
      | [string:price] | [string:float]  |

  Scenario Outline: models should respond to hydra attributes
      Then model "<model>" <action> respond to "<attributes>"

    Scenarios: hydra attributes
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