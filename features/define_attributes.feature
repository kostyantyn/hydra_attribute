Feature: define hydra attributes
  Models should respond to hydra attributes

  Model should respond to hydra attributes if they are described in the class.
  Model should not respond to hydra attribute if it isn't described in it class.

  Background: create models and describe hydra attributes
    Given removed constants if they exist:
      | name          |
      | GroupProduct  |
      | SimpleProduct |
      | Product       |
    And create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type   | name |
      | string | code |
    And create model class "GroupProduct" as "Product" with hydra attributes:
      | type    | name  |
      | float   | price |

  Scenario Outline: models should respond to hydra attributes
    Then model "<model>" should "<respond>" to "<attributes>"

    Scenarios: model should respond to own hydra attributes
      | model         | respond    | attributes              |
      | SimpleProduct | should     | code                    |
      | SimpleProduct | should     | code=                   |
      | SimpleProduct | should     | code?                   |
      | SimpleProduct | should     | code_before_type_cast   |
      | SimpleProduct | should     | code_changed?           |
      | SimpleProduct | should     | code_change             |
      | SimpleProduct | should     | code_will_change!       |
      | SimpleProduct | should     | code_was                |
      | SimpleProduct | should     | reset_code!             |
      | SimpleProduct | should_not | price                   |
      | SimpleProduct | should_not | price=                  |
      | SimpleProduct | should_not | price?                  |
      | SimpleProduct | should_not | price_before_type_cast  |
      | SimpleProduct | should_not | price_changed?          |
      | SimpleProduct | should_not | price_change            |
      | SimpleProduct | should_not | price_will_change!      |
      | SimpleProduct | should_not | price_was               |
      | SimpleProduct | should_not | reset_price!            |
      | GroupProduct  | should     | price                   |
      | GroupProduct  | should     | price=                  |
      | GroupProduct  | should     | price?                  |
      | GroupProduct  | should     | price_before_type_cast  |
      | GroupProduct  | should     | price_changed?          |
      | GroupProduct  | should     | price_change            |
      | GroupProduct  | should     | price_will_change!      |
      | GroupProduct  | should     | price_was               |
      | GroupProduct  | should     | reset_price!            |
      | GroupProduct  | should_not | code                    |
      | GroupProduct  | should_not | code=                   |
      | GroupProduct  | should_not | code?                   |
      | GroupProduct  | should_not | code_before_type_cast   |
      | GroupProduct  | should_not | code_changed?           |
      | GroupProduct  | should_not | code_change             |
      | GroupProduct  | should_not | code_will_change!       |
      | GroupProduct  | should_not | code_was                |
      | GroupProduct  | should_not | reset_code!             |