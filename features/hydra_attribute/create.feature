Feature: create hydra attributes
  When new hydra attribute is created
  Then entity should respond to it

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | price | float        | [bool:t]   |

  Scenario: create hydra attribute
    # Important: when respond_to? is called the hydra attributes are being loaded for entity class
    Then model "Product" should respond to "price"
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type |
      | title | string       |
    Then model "Product" should respond to "title"

  Scenario: create attribute but don't add it to white list
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | code  | string       |            |
      | total | integer      | [bool:f]   |
    Then class "Product" should not have "code" in white list
    And class "Product" should not have "total" in white list

  Scenario: create attribute and add it to white list
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name | backend_type | white_list |
      | code | string       | [bool:t]   |
    Then class "Product" should have "code" in white list