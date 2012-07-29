Feature: update hydra attributes
  When update attribute
  Then entity should be touched

  Background: create hydra attributes
    Given create hydra attributes for "Product" as "hashes":
      | name  | backend_type | default_value |
      | code  | string       | [string:###]  |
      | title | string       |               |
      | total | integer      | [integer:1]   |
    And create "Product" model

  Scenario Outline: update attributes
    Given select last "Product" record
    When  assign attributes as "rows_hash":
      | code  | <set code>  |
      | title | <set title> |
      | total | <set total> |
    And save record
    Then last created "Product" should have the following attributes:
      | code  | <code>  |
      | title | <title> |
      | total | <total> |

    Scenarios: attributes
      | set code   | set title  | set total   | code         | title      | total       |
      | [string:a] | [string:b] | [integer:2] | [string:a]   | [string:b] | [integer:2] |
      | [string:]  | [string:]  | [nil:]      | [string:]    | [string:]  | [nil:]      |
      |            |            | [string:3]  | [string:###] | [nil:]     | [integer:3] |

  # Is a better solution to call several scenarios but don't call hooks and backgrounds before?
  Scenario: update the same model several times
    Given select first "Product" record
    And save record
    Then last created "Product" should have the following attributes:
      | code  | [string:###] |
      | title | [nil:]       |
      | total | [integer:1]  |

    When assign attributes as "rows_hash":
      | title | [string:] |
      | total | [nil:]    |
    And save record
    Then last created "Product" should have the following attributes:
      | code  | [string:###] |
      | title | [string:]    |
      | total | [nil:]       |

    When assign attributes as "rows_hash":
      | code  | [string:a] |
      | total | [string:2] |
    And save record
    Then last created "Product" should have the following attributes:
      | code  | [string:a]  |
      | title | [string:]   |
      | total | [integer:2] |

    When assign attributes as "rows_hash":
      | title | [string:b] |
    And save record
    Then last created "Product" should have the following attributes:
      | code  | [string:a]  |
      | title | [string:b]  |
      | total | [integer:2] |

  Scenario: touch entity when attribute is updated
    Given select last "Product" record
    And keep "updated_at" attribute
    And save record
    Then attribute "updated_at" should be the same

    Given select last "Product" record
    And keep "updated_at" attribute
    When assign attributes as "rows_hash":
      | code  | [string:###] |
      | total | [integer:1]  |
    And save record
    Then attribute "updated_at" should be the same

    Given select last "Product" record
    And keep "updated_at" attribute
    When assign attributes as "rows_hash":
      | code | [nil:] |
    And save record
    Then attribute "updated_at" should not be the same

    Given select last "Product" record
    And keep "updated_at" attribute
    When assign attributes as "rows_hash":
      | code | [nil:] |
    And save record
    Then attribute "updated_at" should be the same

    Given select last "Product" record
    And keep "updated_at" attribute
    When assign attributes as "rows_hash":
      | total | [nil:] |
    And save record
    Then attribute "updated_at" should not be the same

    Given select last "Product" record
    And keep "updated_at" attribute
    When assign attributes as "rows_hash":
      | code | [string:] |
    And save record
    Then attribute "updated_at" should not be the same

    Given select last "Product" record
    And keep "updated_at" attribute
    When assign attributes as "rows_hash":
      | title | [string:]   |
      | total | [integer:0] |
    And save record
    Then attribute "updated_at" should not be the same