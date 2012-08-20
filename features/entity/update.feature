Feature: update hydra attributes
  When update hydra attribute
  Then updated_at for entity should be updated

  When update hydra_set_id
  Then entity should have hydra attributes from this hydra set

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | default_value | white_list     |
      | code  | string       | ###           | [boolean:true] |
      | title | string       |               | [boolean:true] |
      | total | integer      | 1             | [boolean:true] |
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
      | set code  | set title | set total   | code      | title     | total       |
      | a         | b         | [integer:2] | a         | b         | [integer:2] |
      | [string:] | [string:] | [nil:]      | [string:] | [string:] | [nil:]      |
      |           |           | 3           | ###       | [nil:]    | [integer:3] |

  Scenario: update the same model several times to test touch method
    Given select first "Product" record
    And save record
    Then last created "Product" should have the following attributes:
      | code  | ###         |
      | title | [nil:]      |
      | total | [integer:1] |

    When assign attributes as "rows_hash":
      | title | [string:] |
      | total | [nil:]    |
    And save record
    Then last created "Product" should have the following attributes:
      | code  | ###       |
      | title | [string:] |
      | total | [nil:]    |

    When assign attributes as "rows_hash":
      | code  | a |
      | total | 2 |
    And save record
    Then last created "Product" should have the following attributes:
      | code  | a           |
      | title | [string:]   |
      | total | [integer:2] |

    When assign attributes as "rows_hash":
      | title | b |
    And save record
    Then last created "Product" should have the following attributes:
      | code  | a           |
      | title | b           |
      | total | [integer:2] |

  Scenario: touch entity when attribute is updated
    Given select last "Product" record
    And keep "updated_at" attribute
    And save record
    Then attribute "updated_at" should be the same

    Given select last "Product" record
    And keep "updated_at" attribute
    When assign attributes as "rows_hash":
      | code  | ###         |
      | total | [integer:1] |
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