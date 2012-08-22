Feature: update hydra attribute
  When update hydra attribute data
  Then model should be notified about this

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name | backend_type | default_value | white_list |
      | code | integer      | 1             | [bool:t]   |

  Scenario: update default value
    Given create "Product" model
    And load and update attributes for "HydraAttribute::HydraAttribute" models with attributes as "rows_hash":
      | default_value | 2 |
    And create "Product" model
    Then first created "Product" should have the following attributes:
      | code | [int:1] |
    And last created "Product" should have the following attributes:
      | code | [int:2] |

  Scenario: update white list attribute to true
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | title | string       | [bool:f]   |
    And select last "HydraAttribute::HydraAttribute" record
    When update attributes as "admin":
      | white_list | [bool:t] |
    Then class "Product" should have "title" in white list

  Scenario: update white list attribute to false
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name | backend_type | white_list |
      | info | string       | [bool:t]   |
    And select last "HydraAttribute::HydraAttribute" record
    When update attributes as "admin":
      | white_list | [bool:f] |
    Then class "Product" should not have "info" in white list