Feature: create hydra attributes
  When new hydra attribute is created
  Then entity should respond to it

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name           | backend_type   | white_list     |
      | [string:price] | [string:float] | [boolean:true] |

  Scenario: create hydra attribute in runtime
    # Important: when respond_to? is called the hydra attributes are being loaded for entity class
    Then model "Product" should respond to "price"
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type |
      | title | string       |
    Then model "Product" should respond to "title"

  Scenario: create hydra attribute from entity class
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name | backend_type |
      | code | integer      |
    Then model "Product" should respond to "code"
