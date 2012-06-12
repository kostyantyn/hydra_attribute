Feature: hydra attribute where conditions
  When filter by hydra attribute and this value is not nil
  Then the correct hydra attribute table should be joined and filter by this value should be added

  When filter by hydra attribute and this value is nil
  Then records with nil value should be selected  or records which don't have this hydra attribute

  Background: create models and describe hydra attributes
    Given create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type    | name    |
      | string  | code    |
      | string  | summary |
      | string  | title   |
      | float   | price   |
      | boolean | active  |
      | integer | state   |

  Scenario: add filter by one hydra attribute
    Given create models:
      | model         | attributes                         |
      | SimpleProduct | code=[string:1] price=[float:2.75] |
      | SimpleProduct | code=[string:2] price=[float:2.75] |
      | SimpleProduct | code=[string:3] price=[float:2.76] |
      | SimpleProduct | code=[string:4] price=[nil:]       |
    When filter "SimpleProduct" by:
      | field | value         |
      | price | [string:2.75] |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value      |
      | code  | [string:1] |
      | code  | [string:2] |

  Scenario: add nil filter by one hydra attribute
    Given create models:
      | model         | attributes                      |
      | SimpleProduct | code=[string:1] price=[nil:]    |
      | SimpleProduct | code=[string:2] price=[float:0] |
      | SimpleProduct | code=[string:3]                 |
    When filter "SimpleProduct" by:
      | field | value  |
      | price | [nil:] |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value      |
      | code  | [string:1] |
      | code  | [string:3] |

  Scenario: add filter by several fields including both the hydra and general attributes
    Given create models:
      | model         | attributes                                                                                                                                   |
      | SimpleProduct | name=[string:toy] code=[string:1] title=[string:story] price=[float:2.45] active=[boolean:true]               info=[string:]                 |
      | SimpleProduct | name=[string:toy] code=[string:2] title=[string:story] price=[float:2.45] active=[boolean:true]               info=[string:a] summary=[nil:] |
      | SimpleProduct | name=[string:toy] code=[string:3] title=[string:story] price=[float:2.45] active=[boolean:true]  state=[nil:] info=[string:a] summary=[nil:] |
      | SimpleProduct | name=[string:toy] code=[string:4]                      price=[float:2.45] active=[boolean:false] state=[nil:] info=[string:a] summary=[nil:] |
      | SimpleProduct |                   code=[string:5]                      price=[float:2.45] active=[boolean:true]  state=[nil:] info=[string:a] summary=[nil:] |
      | SimpleProduct | name=[string:toy] code=[string:6]                      price=[float:2.46] active=[boolean:true]  state=[nil:] info=[string:a] summary=[nil:] |
    When filter "SimpleProduct" by:
      | field   | value          |
      | name    | [string:toy]   |
      | title   | [string:story] |
      | summary | [nil:]         |
      | price   | [string:2.45]  |
      | active  | [boolean:true] |
      | info    | [string:a]     |
      | state   | [nil:]         |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value      |
      | code  | [string:2] |
      | code  | [string:3] |