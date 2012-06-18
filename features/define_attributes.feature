Feature: define hydra attributes
  When use_hydra_attributes was called in model class
  Then model's object should respond to attributes which are saved in hydra_attributes table

  Background: create hydra attributes
    Given create "HydraAttribute::HydraAttribute" models with attributes:
      | entity_type | name  | backend_type | default_value |
      | Product     | code  | string       |               |
      | Product     | price | float        |               |
    And create class "Product" as "ActiveRecord::Base"
    And call "use_hydra_attributes" inside class "Product"

  Scenario Outline: models should respond to hydra attributes
    Then model "<model>" should "<respond>" to "<attributes>"

    Scenarios: model should respond to own hydra attributes
      | model   | respond | attributes             |
      | Product | should  | code                   |
      | Product | should  | code=                  |
      | Product | should  | code?                  |
      | Product | should  | code_before_type_cast  |
      | Product | should  | code_changed?          |
      | Product | should  | code_change            |
      | Product | should  | code_will_change!      |
      | Product | should  | code_was               |
      | Product | should  | reset_code!            |
      | Product | should  | price                  |
      | Product | should  | price=                 |
      | Product | should  | price?                 |
      | Product | should  | price_before_type_cast |
      | Product | should  | price_changed?         |
      | Product | should  | price_change           |
      | Product | should  | price_will_change!     |
      | Product | should  | price_was              |
      | Product | should  | reset_price!           |
