Feature: select concrete attributes
  When select concrete attribute
  Then model should response only to these attributes

  Background: create hydra attributes
    Given create "HydraAttribute::HydraAttribute" models with attributes as "hashes":
      | entity_type | name     | backend_type |
      | Product     | code     | integer      |
      | Product     | price    | float        |
      | Product     | title    | string       |
      | Product     | note     | text         |
      | Product     | active   | boolean      |
      | Product     | schedule | datetime     |
    And create "Product" model with attributes as "hashes":
      | name       | code        | price     | title      | note       | active          | schedule              |
      | [string:a] | [integer:1] | [float:4] | [string:q] | [string:z] | [boolean:true]  | [datetime:2012-06-01] |
      | [string:b] | [integer:2] | [float:5] | [string:w] | [string:x] | [boolean:false] | [datetime:2012-06-02] |
      | [string:c] | [integer:3] | [float:6] |            | [string:c] | [boolean:true]  | [datetime:2012-06-03] |
      | [string:d] | [nil:]      | [float:7] |            | [string:v] | [boolean:false] | [datetime:2012-06-04] |

  Scenario Outline: select concrete attributes
    When "Product" select only the following columns "<selected columns>"
    Then records should have only the following "<expected columns>" names
    And records should raise "ActiveModel::MissingAttributeError" when call the following "<methods>"
    And total records should be "4"

    Scenarios: select attributes
      | selected columns  | expected columns     | methods                               |
      | name              | name                 | code price title note active schedule |
      | name code         | id name code         | price title note active schedule      |
      | name code price   | id name code price   | title note active schedule            |
      | code price title  | id code price title  | name note active schedule             |
      | title note active | id title note active | name code price schedule              |
      | schedule          | id schedule          | name code price title note active     |
      | id schedule       | id schedule          | name code price title note active     |

  Scenario Outline: filter collection and select concrete attributes
    When "Product" select only the following columns "<selected columns>"
    And filter records by "<filter attributes>"
    Then records should have only the following "<expected columns>" names
    And records should raise "ActiveModel::MissingAttributeError" when call the following "<methods>"
    And total records should be "<total>"

    Scenarios: filter and select attributes
      | selected columns | expected columns | filter attributes | methods                               | total |
      | name code        | id name code     | name=[string:a]   | price title note active schedule      | 1     |
      | code             | id code          | code=[integer:1]  | name price title note active schedule | 1     |
      | name code        | id name code     | code=[integer:1]  | price title note active schedule      | 1     |
      | code title       | id code title    | title=[nil:]      | name price note active schedule       | 2     |
      | code note        | id code note     | title=[nil:]      | name price title active schedule      | 2     |