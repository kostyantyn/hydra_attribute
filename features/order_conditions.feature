Feature: order conditions by hydra attributes
  When order records by hydra attribute
  Then correct table should be joined and order by value should be added

  When correct table is already joined
  Then only order condition should be added

  When order by several attributes
  Then order all of them by ascending

  Background: create models and describe hydra attributes
    Given removed constants if they exist:
      | name          |
      | GroupProduct  |
      | SimpleProduct |
      | Product       |
    And create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type    | name  |
      | integer | code  |
      | integer | state |
      | string  | title |

  Scenario Outline: order by one field
    Given create models:
      | model         | attributes                                         |
      | SimpleProduct | name=[string:c] code=[integer:1] state=[integer:1] |
      | SimpleProduct | name=[string:b] code=[integer:2] state=[integer:2] |
      | SimpleProduct | name=[string:a] code=[integer:3] state=[integer:3] |
    When order "SimpleProduct" records by "<attributes>"
    Then "first" record should have "<first>"
    And "last" record should have "<last>"

    Scenarios: order conditions
      | attributes | first            | last             |
      | state=asc  | code=[integer:1] | code=[integer:3] |
      | state=desc | code=[integer:3] | code=[integer:1] |
      | name=asc   | code=[integer:3] | code=[integer:1] |
      | name=desc  | code=[integer:1] | code=[integer:3] |

  Scenario Outline: order by several fields
    Given create models:
      | model         | attributes                                                          |
      | SimpleProduct | name=[string:c] code=[integer:1] state=[integer:1] title=[string:b] |
      | SimpleProduct | name=[string:b] code=[integer:2] state=[integer:2] title=[string:a] |
      | SimpleProduct | name=[string:a] code=[integer:3] state=[integer:3] title=[string:c] |
    When order "SimpleProduct" records by "<attributes>"
    Then "first" record should have "<first>"
    And "last" record should have "<last>"

    Scenarios: order conditions
      | attributes  | first            | last             |
      | name state  | code=[integer:3] | code=[integer:1] |
      | state title | code=[integer:1] | code=[integer:3] |
      | title state | code=[integer:2] | code=[integer:3] |