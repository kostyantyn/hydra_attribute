Feature: reorder by hydra attributes
  When reorder relation object with new hydra attributes
  Then old order hydra attributes should be removed
  And new hydra attributes should be added to order list

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | code  | integer      | [bool:t]   |
      | state | integer      | [bool:t]   |
      | title | string       | [bool:t]   |

  Scenario Outline: reorder
    Given create "Product" model with attributes as "hashes":
      | code | name | title |
      | 1    | a    | c     |
      | 2    | b    | b     |
      | 3    | c    | a     |
    When order "Product" records by "<order>"
    And reorder records by "<reorder>"
    Then total records should be "<count>"
    And "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | order | reorder    | count | first identifier | last identifier |
      | title | name title | 3     | code=[int:1]     | code=[int:3]    |
      | name  | title name | 3     | code=[int:3]     | code=[int:1]    |
      | code  | title      | 3     | code=[int:3]     | code=[int:1]    |