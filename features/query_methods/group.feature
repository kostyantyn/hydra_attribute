Feature: group conditions by hydra attributes
  When group by hydra attribute
  Then correct table should be joined and group condition should be added

  Background: create models and describe hydra attributes
    Given create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type    | name  |
      | integer | code  |
      | string  | title |
      | integer | total |
    And create models:
      | model         | attributes                                                          |
      | SimpleProduct | name=[string:a] code=[integer:1] title=[string:q] total=[integer:5] |
      | SimpleProduct | name=[string:b] code=[integer:2] title=[string:w] total=[integer:5] |
      | SimpleProduct | name=[string:b] code=[integer:3] title=[string:w] total=[nil:]      |
      | SimpleProduct | name=[string:c] code=[integer:4] title=[string:e]                   |

  Scenario Outline: group by attributes
    When group "SimpleProduct" by "<group by>"
    Then total records should be "<total>"
    And "first" record should have "<first attribute>"
    And "last" record should have "<last attribute>"

    Scenarios: group attributes
      | group by   | total | first attribute                  | last attribute                   |
      | code       | 4     | code=[integer:1]                 | code=[integer:4]                 |
      | name       | 3     | name=[string:a] code=[integer:1] | name=[string:c] code=[integer:4] |
      | name title | 3     | name=[string:a] code=[integer:1] | name=[string:c] code=[integer:4] |

  Scenario Outline: group by attributes with filter
    When group "SimpleProduct" by "<group by>"
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