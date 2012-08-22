Feature: order conditions by hydra attributes
  When order records by hydra attribute
  Then correct table should be joined and order by value should be added

  When correct table is already joined
  Then only order condition should be added

  When order by several attributes
  Then order all of them by ascending

  When reorder by attributes
  Then old hydra attributes should be removed and new should be added

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | code  | integer      | [bool:t]   |
      | state | integer      | [bool:t]   |
      | title | string       | [bool:t]   |

  Scenario Outline: order by one field
    Given create "Product" model with attributes as "hashes":
      | name | code | state |
      | c    | 1    | 1     |
      | b    | 2    | 2     |
      | a    | 3    | 3     |
    When order "Product" records by "<attributes>"
    Then "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | attributes | first identifier | last identifier |
      | state=asc  | code=[int:1]     | code=[int:3]    |
      | state=desc | code=[int:3]     | code=[int:1]    |
      | name=asc   | code=[int:3]     | code=[int:1]    |
      | name=desc  | code=[int:1]     | code=[int:3]    |

  Scenario Outline: order by several attributes
    Given create "Product" model with attributes as "hashes":
      | name | code | state | title |
      | c    | 1    | 1     | b     |
      | b    | 2    | 2     | a     |
      | a    | 3    | 3     | c     |
    When order "Product" records by "<attributes>"
    Then "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | attributes  | first identifier | last identifier |
      | name state  | code=[int:3]     | code=[int:1]    |
      | state title | code=[int:1]     | code=[int:3]    |
      | title state | code=[int:2]     | code=[int:3]    |

  Scenario Outline: order by filtered attribute
    Given create "Product" model with attributes as "hashes":
      | code | state | title |
      | 1    | 1     |       |
      | 2    |       |       |
      | 3    | 1     | a     |
    When filter "Product" records by "<filter attribute>"
    And order records by "<order attributes>"
    Then total records should be "<count>"
    And "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | filter attribute | order attributes | count | first identifier | last identifier |
      | state=[int:1]    | state code       | 2     | code=[int:1]     | code=[int:3]    |
      | state=[nil:]     | state code       | 1     | code=[int:2]     | code=[int:2]    |
      | title=[nil:]     | title code       | 2     | code=[int:1]     | code=[int:2]    |

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

  Scenario: reverse order
    Given create "Product" model with attributes as "hashes":
      | code | title |
      | 1    | a     |
      | 2    | b     |
      | 3    | c     |
    When order "Product" records by "title"
    And reverse order records
    Then total records should be "3"
    And "first" record should have "code=[int:3]"
    And "last" record should have "code=[int:1]"