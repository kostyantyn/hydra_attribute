Feature: hydra attribute where conditions
  When filter by hydra attribute and this value is not nil
  Then records with this attribute should be selected

  When filter by hydra attribute and this value is nil
  Then records with nil and blank value should be selected

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name    | backend_type | white_list     |
      | code    | string       | [boolean:true] |
      | summary | string       | [boolean:true] |
      | title   | string       | [boolean:true] |
      | price   | float        | [boolean:true] |
      | active  | boolean      | [boolean:true] |
      | state   | integer      | [boolean:true] |

  Scenario: filter by one hydra attribute
    Given create "Product" model with attributes as "hashes":
      | code | price        |
      | 1    | [float:2.75] |
      | 2    | [float:2.75] |
      | 3    | [float:2.76] |
      | 4    | [nil:]       |
    When filter "Product" by:
      | field | value |
      | price | 2.75  |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value |
      | code  | 1     |
      | code  | 2     |

  Scenario: filter by one hydra attribute with nil value
    Given create "Product" model with attributes as "hashes":
      | code | price     |
      | 1    | [nil:]    |
      | 2    | [float:0] |
      | 3    |           |
    When filter "Product" by:
      | field | value  |
      | price | [nil:] |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value |
      | code  | 1     |
      | code  | 3     |

  Scenario: filter by several fields including both the hydra and general attributes
    Given create "Product" model with attributes as "hashes":
      | name | code | title | price        | active          | state  | summary |
      | toy  | 1    | story | [float:2.40] | [boolean:true]  |        |         |
      | toy  | 2    | story | [float:2.45] | [boolean:true]  |        | [nil:]  |
      | toy  | 3    | story | [float:2.45] | [boolean:true]  | [nil:] | [nil:]  |
      | toy  | 4    |       | [float:2.45] | [boolean:false] | [nil:] | [nil:]  |
      |      | 5    |       | [float:2.45] | [boolean:true]  | [nil:] | [nil:]  |
      | toy  | 6    |       | [float:2.46] | [boolean:true]  | [nil:] | [nil:]  |
    When filter "Product" by:
      | field   | value          |
      | name    | toy            |
      | title   | story          |
      | summary | [nil:]         |
      | price   | [float:2.45]   |
      | active  | [boolean:true] |
      | state   | [nil:]         |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value |
      | code  | 2     |
      | code  | 3     |