Feature: select concrete attributes
  When select hydra attribute
  Then hydra attribute table should be joined and concrete attribute should be selected

  Background: create models and describe hydra attributes
    Given create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type     | name     |
      | integer  | code     |
      | float    | price    |
      | string   | title    |
      | text     | note     |
      | boolean  | active   |
      | datetime | schedule |
    And create models:
      | model         | attributes                                                                                                                              |
      | SimpleProduct | name=[string:a] code=[integer:1] price=[float:4] title=[string:q] note=[string:z] active=[boolean:true]  schedule=[datetime:2012-06-01] |
      | SimpleProduct | name=[string:b] code=[integer:2] price=[float:5] title=[string:w] note=[string:x] active=[boolean:false] schedule=[datetime:2012-06-02] |
      | SimpleProduct | name=[string:c] code=[integer:3] price=[float:6]                  note=[string:c] active=[boolean:true]  schedule=[datetime:2012-06-03] |
      | SimpleProduct | name=[string:d] code=[nil:]      price=[float:7]                  note=[string:v] active=[boolean:false] schedule=[datetime:2012-06-04] |

  Scenario Outline: select concrete attributes
    When "SimpleProduct" select only the following columns "<columns>"
    Then records should have only the following "<columns>" names
    And records should raise "ActiveModel::MissingAttributeError" when call the following "<methods>"
    And total records should be "4"

      Scenarios: select attributes
        | columns           | methods                               |
        | name              | code price title note active schedule |
        | name code         | price title note active schedule      |
        | name code price   | title note active schedule            |
        | code price title  | name note active schedule             |
        | title note active | name code price schedule              |
        | schedule          | name code price title note active     |
        | id schedule       | name code price title note active     |

  Scenario Outline: filter collection and select concrete attributes
    When "SimpleProduct" select only the following columns "<columns>"
    And filter records by "<filter attributes>"
    Then records should have only the following "<columns>" names
    And records should raise "ActiveModel::MissingAttributeError" when call the following "<methods>"
    And total records should be "<total>"

    Scenarios: filter and select attributes
      | columns    | filter attributes | methods                               | total |
      | name code  | name=[string:a]   | price title note active schedule      | 1     |
      | code       | code=[integer:1]  | name price title note active schedule | 1     |
      | name code  | code=[integer:1]  | price title note active schedule      | 1     |
      | code title | title=[nil:]      | name price note active schedule       | 2     |
      | code note  | title=[nil:]      | name price title active schedule      | 2     |