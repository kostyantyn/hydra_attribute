Feature: select concrete attributes
  When select concrete attribute
  Then model should response only to these attributes

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name     | backend_type | white_list |
      | code     | integer      | [bool:t]   |
      | price    | float        | [bool:t]   |
      | title    | string       | [bool:t]   |
      | note     | text         | [bool:t]   |
      | active   | boolean      | [bool:t]   |
      | schedule | datetime     | [bool:t]   |
    And create "Product" model with attributes as "hashes":
      | name | code | price | title | note | active | schedule   |
      | a    | 1    | 4     | q     | z    | 1      | 2012-06-01 |
      | b    | 2    | 5     | w     | x    | 0      | 2012-06-02 |
      | c    | 3    | 6     |       | c    | 1      | 2012-06-03 |
      | d    |      | 7     |       | v    | 0      | 2012-06-04 |

  Scenario Outline: select concrete attributes
    When "Product" select only the following columns "<selected columns>"
    Then records should have only the following "<expected columns>" names
    And records should raise "ActiveModel::MissingAttributeError" when call the following "<methods>"
    And total records should be "4"

    Scenarios: select attributes
      | selected columns  | expected columns                  | methods                               |
      | name              | id hydra_set_id name              | code price title note active schedule |
      | name code         | id hydra_set_id name code         | price title note active schedule      |
      | name code price   | id hydra_set_id name code price   | title note active schedule            |
      | code price title  | id hydra_set_id code price title  | name note active schedule             |
      | title note active | id hydra_set_id title note active | name code price schedule              |
      | schedule          | id hydra_set_id schedule          | name code price title note active     |
      | id schedule       | id hydra_set_id schedule          | name code price title note active     |

  Scenario Outline: filter collection and select concrete attributes
    When "Product" select only the following columns "<selected columns>"
    And filter records by "<filter attributes>"
    Then records should have only the following "<expected columns>" names
    And records should raise "ActiveModel::MissingAttributeError" when call the following "<methods>"
    And total records should be "<total>"

    Scenarios: filter and select attributes
      | selected columns | expected columns           | filter attributes | methods                               | total |
      | name code        | id hydra_set_id name code  | name=a            | price title note active schedule      | 1     |
      | code             | id hydra_set_id code       | code=[int:1]      | name price title note active schedule | 1     |
      | name code        | id hydra_set_id name code  | code=[int:1]      | price title note active schedule      | 1     |
      | code title       | id hydra_set_id code title | title=[nil:]      | name price note active schedule       | 2     |
      | code note        | id hydra_set_id code note  | title=[nil:]      | name price title active schedule      | 2     |