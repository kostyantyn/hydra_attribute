Feature: update hydra attribute
  When update hydra attribute data
  Then model should be notified about this

  Background: create hydra attributes
    Given create "HydraAttribute::HydraAttribute" model with attributes as "hashes":
      | entity_type | name | backend_type | default_value |
      | Product     | code | integer      | 1             |

  Scenario: update default value in runtime
    Given create "Product" model
    And load and update attributes for "HydraAttribute::HydraAttribute" models with attributes as "rows_hash":
      | default_value | 2 |
    And create "Product" model
    Then first created "Product" should have the following attributes:
      | code | [integer:1] |
    And last created "Product" should have the following attributes:
      | code | [integer:2] |

