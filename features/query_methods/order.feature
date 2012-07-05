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
    Given create "HydraAttribute::HydraAttribute" models with attributes as "hashes":
      | entity_type | name  | backend_type |
      | Product     | code  | integer      |
      | Product     | state | integer      |
      | Product     | title | string       |

  Scenario Outline: order by one field
    Given create "Product" model with attributes as "hashes":
      | name       | code        | state       |
      | [string:c] | [integer:1] | [integer:1] |
      | [string:b] | [integer:2] | [integer:2] |
      | [string:a] | [integer:3] | [integer:3] |
    When order "Product" records by "<attributes>"
    Then "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | attributes | first identifier | last identifier  |
      | state=asc  | code=[integer:1] | code=[integer:3] |
      | state=desc | code=[integer:3] | code=[integer:1] |
      | name=asc   | code=[integer:3] | code=[integer:1] |
      | name=desc  | code=[integer:1] | code=[integer:3] |

  Scenario Outline: order by several attributes
    Given create "Product" model with attributes as "hashes":
      | name       | code        | state       | title      |
      | [string:c] | [integer:1] | [integer:1] | [string:b] |
      | [string:b] | [integer:2] | [integer:2] | [string:a] |
      | [string:a] | [integer:3] | [integer:3] | [string:c] |
    When order "Product" records by "<attributes>"
    Then "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | attributes  | first identifier | last identifier  |
      | name state  | code=[integer:3] | code=[integer:1] |
      | state title | code=[integer:1] | code=[integer:3] |
      | title state | code=[integer:2] | code=[integer:3] |

  Scenario Outline: order by filtered attribute
    Given create "Product" model with attributes as "hashes":
      | code        | state       | title      |
      | [integer:1] | [integer:1] |            |
      | [integer:2] |             | [nil:]     |
      | [integer:3] | [integer:1] | [string:a] |
    When filter "Product" records by "<filter attribute>"
    And order records by "<order attributes>"
    Then total records should be "<count>"
    And "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | filter attribute  | order attributes | count | first identifier | last identifier  |
      | state=[integer:1] | state code       | 2     | code=[integer:1] | code=[integer:3] |
      | state=[nil:]      | state code       | 1     | code=[integer:2] | code=[integer:2] |
      | title=[nil:]      | title code       | 2     | code=[integer:1] | code=[integer:2] |

  Scenario Outline: reorder
    Given create "Product" model with attributes as "hashes":
      | code        | name       | title      |
      | [integer:1] | [string:a] | [string:c] |
      | [integer:2] | [string:b] | [string:b] |
      | [integer:3] | [string:c] | [string:a] |
    When order "Product" records by "<order>"
    And reorder records by "<reorder>"
    Then total records should be "<count>"
    And "first" record should have "<first identifier>"
    And "last" record should have "<last identifier>"

    Scenarios: order conditions
      | order | reorder    | count | first identifier | last identifier  |
      | title | name title | 3     | code=[integer:1] | code=[integer:3] |
      | name  | title name | 3     | code=[integer:3] | code=[integer:1] |

  Scenario: reverse order
    Given create "Product" model with attributes as "hashes":
      | code        | title      |
      | [integer:1] | [string:a] |
      | [integer:2] | [string:b] |
      | [integer:3] | [string:c] |
    When order "Product" records by "title"
    And reverse order records
    Then total records should be "3"
    And "first" record should have "code=[integer:3]"
    And "last" record should have "code=[integer:1]"