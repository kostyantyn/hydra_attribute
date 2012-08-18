Feature: destroy hydra set
  When destroy hydra set
  Then column hydra_set_id should be set to NULL for entity tables

  Scenario: destroy hydra set
    Given create hydra sets for "Product" as "rows_hash":
      | name | [string:Default] |
    And create "Product" model with attributes as "rows_hash":
      | hydra_set_id | [eval:Product.hydra_sets.find_by_name('Default').id] |
    When destroy all "HydraAttribute::HydraSet" models with attributes as "rows_hash":
      | name | Default |
    Then last created "Product" should have the following attributes:
      | hydra_set_id | [nil:] |