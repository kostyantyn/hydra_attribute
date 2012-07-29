Feature: hydra attribute where conditions
  When filter by hydra attribute and this value is not nil
  Then records with this attribute should be selected

  When filter by hydra attribute and this value is nil
  Then records with nil and blank value should be selected

  Background: create hydra attributes
    Given create hydra attributes for "Product" as "hashes":
      | name    | backend_type |
      | code    | string       |
      | summary | string       |
      | title   | string       |
      | price   | float        |
      | active  | boolean      |
      | state   | integer      |

  Scenario: filter by one hydra attribute
    Given create "Product" model with attributes as "hashes":
      | code       | price        |
      | [string:1] | [float:2.75] |
      | [string:2] | [float:2.75] |
      | [string:3] | [float:2.76] |
      | [string:4] | [nil:]       |
    When filter "Product" by:
      | field | value         |
      | price | [string:2.75] |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value      |
      | code  | [string:1] |
      | code  | [string:2] |

  Scenario: filter by one hydra attribute with nil value
    Given create "Product" model with attributes as "hashes":
      | code       | price     |
      | [string:1] | [nil:]    |
      | [string:2] | [float:0] |
      | [string:3] |           |
    When filter "Product" by:
      | field | value  |
      | price | [nil:] |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value      |
      | code  | [string:1] |
      | code  | [string:3] |

  Scenario: filter by several fields including both the hydra and general attributes
    Given create "Product" model with attributes as "hashes":
      | name         | code       | title          | price        | active          | state  | summary |
      | [string:toy] | [string:1] | [string:story] | [float:2.40] | [boolean:true]  |        |         |
      | [string:toy] | [string:2] | [string:story] | [float:2.45] | [boolean:true]  |        | [nil:]  |
      | [string:toy] | [string:3] | [string:story] | [float:2.45] | [boolean:true]  | [nil:] | [nil:]  |
      | [string:toy] | [string:4] |                | [float:2.45] | [boolean:false] | [nil:] | [nil:]  |
      |              | [string:5] |                | [float:2.45] | [boolean:true]  | [nil:] | [nil:]  |
      | [string:toy] | [string:6] |                | [float:2.46] | [boolean:true]  | [nil:] | [nil:]  |
    When filter "Product" by:
      | field   | value          |
      | name    | [string:toy]   |
      | title   | [string:story] |
      | summary | [nil:]         |
      | price   | [string:2.45]  |
      | active  | [boolean:true] |
      | state   | [nil:]         |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value      |
      | code  | [string:2] |
      | code  | [string:3] |