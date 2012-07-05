Feature: group conditions by hydra attributes
  When group by hydra attribute
  Then correct table should be joined and group condition should be added

  Background: create models and describe hydra attributes
    Given create "HydraAttribute::HydraAttribute" models with attributes as "hashes":
      | entity_type | name  | backend_type |
      | Product     | code  | integer      |
      | Product     | title | string       |
      | Product     | total | integer      |
    Given create "Product" model with attributes as "hashes":
      | name       | code        | title      | total       |
      | [string:a] | [integer:1] | [string:q] | [integer:5] |
      | [string:b] | [integer:2] | [string:w] | [integer:5] |
      | [string:b] | [integer:3] | [string:w] | [nil:]      |
      | [string:c] | [integer:4] | [string:e] |             |

  Scenario Outline: group by attributes
    When group "Product" by "<group by>"
    Then total records should be "<total>"
    And "first" record should have "<first attribute>"
    And "last" record should have "<last attribute>"

    Scenarios: group attributes
      | group by   | total | first attribute                  | last attribute                   |
      | code       | 4     | code=[integer:1]                 | code=[integer:4]                 |
      | name       | 3     | name=[string:a] code=[integer:1] | name=[string:c] code=[integer:4] |
      | name title | 3     | name=[string:a] code=[integer:1] | name=[string:c] code=[integer:4] |

  Scenario Outline: group by attributes with filter
    When group "Product" by "<group by>"
    And filter records by "<filter>"
    Then total records should be "<total>"
    And "first" record should have "<first attribute>"
    And "last" record should have "<last attribute>"

    Scenarios: group attributes
      | group by   | filter           | total | first attribute                  | last attribute                   |
      | code       | title=[string:w] | 2     | code=[integer:2]                 | code=[integer:3]                 |
      | name       | title=[string:w] | 1     | name=[string:b] title=[string:w] | name=[string:b] title=[string:w] |
      | name title | title=[string:w] | 1     | name=[string:b] title=[string:w] | name=[string:b] title=[string:w] |
      | name title | total=[nil:]     | 2     | name=[string:b] title=[string:w] | name=[string:c] title=[string:e] |