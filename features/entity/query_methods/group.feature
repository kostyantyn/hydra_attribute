Feature: group conditions by hydra attributes
  When group by hydra attribute
  Then correct table should be joined and group condition should be added

  Background: create models and describe hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | code  | integer      | [bool:t]   |
      | title | string       | [bool:t]   |
      | total | integer      | [bool:t]   |
    Given create "Product" model with attributes as "hashes":
      | name | code    | title | total   |
      | a    | [int:1] | q     | [int:5] |
      | b    | [int:2] | w     | [int:5] |
      | b    | [int:3] | w     | [nil:]  |
      | c    | [int:4] | e     |         |

  Scenario Outline: group by attributes
    When group "Product" by "<group by>"
    Then total records should be "<total>"
    And "first" record should have "<first attribute>"
    And "last" record should have "<last attribute>"

    Scenarios: group attributes
      | group by   | total | first attribute     | last attribute      |
      | code       | 4     | code=[int:1]        | code=[int:4]        |
      | name       | 3     | name=a code=[int:1] | name=c code=[int:4] |
      | name title | 3     | name=a code=[int:1] | name=c code=[int:4] |

  Scenario Outline: group by attributes with filter
    When group "Product" by "<group by>"
    And filter records by "<filter>"
    Then total records should be "<total>"
    And "first" record should have "<first attribute>"
    And "last" record should have "<last attribute>"

    Scenarios: group attributes
      | group by   | filter       | total | first attribute | last attribute |
      | code       | title=w      | 2     | code=[int:2]    | code=[int:3]   |
      | name       | title=w      | 1     | name=b title=w  | name=b title=w |
      | name title | title=w      | 1     | name=b title=w  | name=b title=w |
      | name title | total=[nil:] | 2     | name=b title=w  | name=c title=e |