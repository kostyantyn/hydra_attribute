Feature: hydra attribute where conditions
  When filter by hydra attribute and this value is not nil
  Then records with this attribute should be selected

  When filter by hydra attribute and this value is nil
  Then records with nil and blank value should be selected

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name    | backend_type | white_list |
      | code    | string       | [bool:t]   |
      | summary | string       | [bool:t]   |
      | title   | string       | [bool:t]   |
      | price   | float        | [bool:t]   |
      | active  | boolean      | [bool:t]   |
      | state   | integer      | [bool:t]   |

  Scenario: filter by one hydra attribute
    Given create "Product" model with attributes as "hashes":
      | code | price |
      | 1    | 2.75  |
      | 2    | 2.75  |
      | 3    | 2.76  |
      | 4    |       |
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
      | code | price |
      | 1    |       |
      | 2    | 0     |
      | 3    |       |
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
      | name | code | title | price | active | state  | summary |
      | toy  | 1    | story | 2.40  | 1      |        |         |
      | toy  | 2    | story | 2.45  | 1      |        |         |
      | toy  | 3    | story | 2.45  | 1      |        |         |
      | toy  | 4    |       | 2.45  | 0      |        |         |
      |      | 5    |       | 2.45  | 1      |        |         |
      | toy  | 6    |       | 2.46  | 1      |        |         |
    When filter "Product" by:
      | field   | value        |
      | name    | toy          |
      | title   | story        |
      | summary | [nil:]       |
      | price   | [float:2.45] |
      | active  | [bool:t]     |
      | state   | [nil:]       |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value |
      | code  | 2     |
      | code  | 3     |

  Scenario: select entity if it has attribute in attribute set
    Given  create hydra set "Default" for "Product"
    And set hydra attributes "[array:code,title]" to hydra set "Default" for entity "Product"
    And create "Product" models with attributes as "hashes":
      | hydra_set_id                           | code | title |
      |                                        | abc1 | book  |
      | [eval:Product.hydra_set('Default').id] | abc2 | book  |
    When filter "Product" by:
      | field | value |
      | title | book  |
    Then total records should be "2"
    And records should have the following attributes:
      | field | value |
      | code  | abc1  |
      | code  | abc2  |

  Scenario: when filter attribute by nil value then entities without this attribute in attribute set should not be selected
    Given create hydra set "Default" for "Product"
    And create "Product" model
    And create "Product" model with attributes as "rows_hash":
      | hydra_set_id | [eval:Product.hydra_set('Default').id] |
    When filter "Product" by:
      | field | value  |
      | code  | [nil:] |
    Then total records should be "1"
    And records should have the following attributes:
      | field        | value  |
      | hydra_set_id | [nil:] |

  Scenario: when filter attribute by value then entities which don't have this attribute in attribute set any more should not be selected
    Given create hydra set "Default" for "Product"
    And add hydra attribute "code" to hydra set "Default" for entity "Product"
    And create "Product" models with attributes as "hashes":
      | hydra_set_id                           | code |
      |                                        | abc  |
      | [eval:Product.hydra_set('Default').id] | abc  |
    And set hydra attributes "title" to hydra set "Default" for entity "Product"
    When filter "Product" by:
      | field | value |
      | code  | abc   |
    Then total records should be "1"
    And records should have the following attributes:
      | field        | value  |
      | hydra_set_id | [nil:] |