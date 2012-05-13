Feature: helper hydra attribute methods
  Model class should return defined hydra attribute types and names.

  Base class should return all  defined hydra attribute types and names from children classes.

  Background: create models and describe hydra attributes
    Given removed constants if they exist:
      | name          |
      | GroupProduct  |
      | SimpleProduct |
      | Product       |
    And create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type   | name  |
      | string | code  |
      | float  | price |
      | text   | info  |
    And create model class "GroupProduct" as "Product" with hydra attributes:
      | type     | name   |
      | integer  | price  |
      | string   | title  |
      | boolean  | active |
      | datetime | launch |

  Scenario Outline: hydra attribute helpers
    Then class "<class>"::"<method>" "<behavior>" have "<param>"

    Scenarios: hydra attribute names
      | class         | method                | behavior   | param                               |
      | SimpleProduct | hydra_attribute_names | should     | code price info                     |
      | SimpleProduct | hydra_attribute_names | should_not | title active launch                 |
      | GroupProduct  | hydra_attribute_names | should     | price title active launch           |
      | GroupProduct  | hydra_attribute_names | should_not | code info                           |
      | Product       | hydra_attribute_names | should     | code price info title active launch |

    Scenarios: hydra attribute types
      | class         | method                | behavior   | param                                      |
      | SimpleProduct | hydra_attribute_types | should     | string float text                          |
      | SimpleProduct | hydra_attribute_types | should_not | integer boolean datetime                   |
      | GroupProduct  | hydra_attribute_types | should     | integer string boolean datetime            |
      | GroupProduct  | hydra_attribute_types | should_not | text float                                 |
      | Product       | hydra_attribute_types | should     | string float text integer boolean datetime |