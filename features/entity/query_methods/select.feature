Feature: select concrete attributes
  When select concrete attribute
  Then model should response only to these attributes

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name     | backend_type | white_list     |
      | code     | integer      | [boolean:true] |
      | price    | float        | [boolean:true] |
      | title    | string       | [boolean:true] |
      | note     | text         | [boolean:true] |
      | active   | boolean      | [boolean:true] |
      | schedule | datetime     | [boolean:true] |
    And create "Product" model with attributes as "hashes":
      | name | code        | price     | title | note | active          | schedule              |
      | a    | [integer:1] | [float:4] | q     | z    | [boolean:true]  | [datetime:2012-06-01] |
      | b    | [integer:2] | [float:5] | w     | x    | [boolean:false] | [datetime:2012-06-02] |
      | c    | [integer:3] | [float:6] |       | c    | [boolean:true]  | [datetime:2012-06-03] |
      | d    | [nil:]      | [float:7] |       | v    | [boolean:false] | [datetime:2012-06-04] |

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
      | name code        | id hydra_set_id name code  | name=[string:a]   | price title note active schedule      | 1     |
      | code             | id hydra_set_id code       | code=[integer:1]  | name price title note active schedule | 1     |
      | name code        | id hydra_set_id name code  | code=[integer:1]  | price title note active schedule      | 1     |
      | code title       | id hydra_set_id code title | title=[nil:]      | name price note active schedule       | 2     |
      | code note        | id hydra_set_id code note  | title=[nil:]      | name price title active schedule      | 2     |