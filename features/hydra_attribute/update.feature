Feature: update hydra attribute
  When update hydra attribute data
  Then model should be notified about this

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name | backend_type | default_value | white_list     |
      | code | integer      | [integer:1]   | [boolean:true] |

  Scenario: update default value
    Given create "Product" model
    And load and update attributes for "HydraAttribute::HydraAttribute" models with attributes as "rows_hash":
      | default_value | 2 |
    And create "Product" model
    Then first created "Product" should have the following attributes:
      | code | [integer:1] |
    And last created "Product" should have the following attributes:
      | code | [integer:2] |

  Scenario: update white list attribute to true
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list      |
      | title | string       | [boolean:false] |
    And select last "HydraAttribute::HydraAttribute" record
    When update attributes as "admin":
      | white_list | [boolean:true] |
    Then class "Product" should have "title" in white list

  Scenario: update white list attribute to false
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name | backend_type | white_list      |
      | info | string       | [boolean:true] |
    And select last "HydraAttribute::HydraAttribute" record
    When update attributes as "admin":
      | white_list | [boolean:false] |
    Then class "Product" should not have "info" in white list