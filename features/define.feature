Feature: define hydra attributes
  When include HydraAttribute::ActiveRecord
  Then entity should respond to attributes which are saved in hydra_attributes table

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name           | backend_type    | white_list      |
      | [string:code]  | [string:string] | [boolean:true]  |
      | [string:price] | [string:float]  | [boolean:false] |

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

  Scenario: model should have appropriate attributes in white list
    When redefine "Product" class to use hydra attributes
    Then class "Product" should have "code" in white list
    And class "Product" should not have "price" in white list