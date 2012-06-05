Feature: helper methods for hydra attributes
  When class calls hydra_attributes
  Then symbolize hash with hydra attribute names and their types should be returned

  When class calls hydra_attribute_names
  Then array with symbolize hydra attribute names should be returned

  When class calls hydra_attribute_types
  Then array with symbolize hydra attribute types should be returned

  When model calls hydra_attributes
  Then stringify hash with hydra attribute names and their values should be returned

  When model calls attributes
  Then stringify hash with both native and hydra attributes should be returned

  When model calls attributes_before_type_cast
  Then stringify hash with both native and hydra attributes should be returned with values before type cast

  When model calls read_attribute on hydra attribute
  Then hydra attribute value should be returned

  When model calls read_attribute_before_type_cast
  Then hydra attribute value before type cast should be returned

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
      | text   | note  |
    And create model class "GroupProduct" as "Product" with hydra attributes:
      | type     | name   |
      | integer  | price  |
      | string   | title  |
      | boolean  | active |
      | datetime | launch |

  Scenario Outline: class hydra_attributes
    Then class "<class>"::"<method>" "<behavior>" have "<param>" hash

    Scenarios: hydra attributes
      | class         | method           | behavior | param                                                     |
      | SimpleProduct | hydra_attributes | should   | code=string price=float note=text                         |
      | GroupProduct  | hydra_attributes | should   | price=integer title=string active=boolean launch=datetime |

  Scenario Outline: class hydra_attribute_names
    Then class "<class>"::"<method>" "<behavior>" have string "<params>" in array

    Scenarios: hydra attribute names
      | class         | method                | behavior   | params                    |
      | SimpleProduct | hydra_attribute_names | should     | code price note           |
      | SimpleProduct | hydra_attribute_names | should_not | title active launch       |
      | GroupProduct  | hydra_attribute_names | should     | price title active launch |
      | GroupProduct  | hydra_attribute_names | should_not | code note                 |

  Scenario Outline: class hydra_attribute_types
    Then class "<class>"::"<method>" "<behavior>" have symbol "<params>" in array

    Scenarios: hydra attribute types
      | class         | method                | behavior   | params                          |
      | SimpleProduct | hydra_attribute_types | should     | string float text               |
      | SimpleProduct | hydra_attribute_types | should_not | integer boolean datetime        |
      | GroupProduct  | hydra_attribute_types | should     | integer string boolean datetime |
      | GroupProduct  | hydra_attribute_types | should_not | text float                      |

  Scenario Outline: model hydra_attributes
    Given create models:
      | model         | attributes                                                                                                        |
      | SimpleProduct | name=[string:a] info=[string:i] code=[string:c] price=[float:2] note=[string:n]                                   |
      | GroupProduct  | name=[string:a] info=[string:i] price=[float:2] title=[string:t] active=[boolean:true] launch=[string:2012-06-03] |
    When select "first" "<model>" record
    Then model "<model>" should have only the following hydra attributes "<attributes>"
    And record should have the following hydra attributes "<values>" in attribute hash

    Scenarios: required hydra attributes
      | model         | attributes                | values                                                                            |
      | SimpleProduct | code price note           | code=[string:c] price=[float:2] note=[string:n]                                   |
      | GroupProduct  | price title active launch | price=[float:2] title=[string:t] active=[boolean:true] launch=[string:2012-06-03] |

  Scenario Outline: model attributes
    Given create models:
      | model         | attributes                                                                                                        |
      | SimpleProduct | name=[string:a] info=[string:i] code=[string:c] price=[float:2] note=[string:n]                                   |
      | GroupProduct  | name=[string:a] info=[string:i] price=[float:2] title=[string:t] active=[boolean:true] launch=[string:2012-06-03] |
    When select "first" "<model>" record
    Then model "<model>" should have only the following attributes "<attributes>"
    And record should have the following attributes "<values>" in attribute hash

    Scenarios: required attributes
      | model         | attributes                                                        | values                                                                                                            |
      | SimpleProduct | id type name info created_at updated_at code price note           | name=[string:a] info=[string:i] code=[string:c] price=[float:2] note=[string:n]                                   |
      | GroupProduct  | id type name info created_at updated_at price title active launch | name=[string:a] info=[string:i] price=[float:2] title=[string:t] active=[boolean:true] launch=[string:2012-06-03] |

  Scenario Outline: model attributes_before_type_cast
    Given create models:
      | model         | attributes                                                                                                        |
      | SimpleProduct | name=[string:a] info=[string:i] code=[string:c] price=[float:2] note=[string:n]                                   |
      | GroupProduct  | name=[string:a] info=[string:i] price=[float:2] title=[string:t] active=[boolean:true] launch=[string:2012-06-07] |
    When select "first" "<model>" record
    Then model "<model>" should have only the following attributes before type cast "<attributes>"
    And record should have the following attributes before type cast "<before type cast values>" in attribute hash

    Scenarios: required before type cast attributes
      | model         | attributes                                                        | before type cast values                                                                                                       |
      | SimpleProduct | id type name info created_at updated_at code price note           | name=[string:a] info=[string:i] code=[string:c] price=[float:2] note=[string:n]                                               |
      | GroupProduct  | id type name info created_at updated_at price title active launch | name=[string:a] info=[string:i] price=[float:2] title=[string:t] active=[string:t] launch=[string:2012-06-07 00:00:00.000000] |

  Scenario Outline: model read_attributes
    Given create models:
      | model         | attributes                                                                                    |
      | SimpleProduct | name=[string:a] info=[string:i] code=[string:c] price=[nil:]                                  |
      | GroupProduct  | name=[string:a] info=[string:i] price=[nil:] active=[boolean:true] launch=[string:2012-06-03] |
    When select "first" "<model>" record
    Then record read attribute "<attribute>" and value should be "<value>"

    Scenarios: read attributes
      | model         | attribute | value                 |
      | SimpleProduct | name      | [string:a]            |
      | SimpleProduct | info      | [string:i]            |
      | SimpleProduct | code      | [string:c]            |
      | SimpleProduct | price     | [nil:]                |
      | SimpleProduct | note      | [nil:]                |
      | GroupProduct  | name      | [string:a]            |
      | GroupProduct  | info      | [string:i]            |
      | GroupProduct  | price     | [nil:]                |
      | GroupProduct  | title     | [nil:]                |
      | GroupProduct  | active    | [boolean:true]        |
      | GroupProduct  | launch    | [datetime:2012-06-03] |

  Scenario Outline: model read_attributes_before_type_cast
    Given create models:
      | model         | attributes                                                        |
      | SimpleProduct | name=[string:a] price=[float:2]                                   |
      | GroupProduct  | name=[string:a] active=[boolean:false] launch=[string:2012-06-03] |
    When select "first" "<model>" record
    Then record read attribute before type cast "<attribute>" and value should be "<value>"

    Scenarios: read attributes
      | model         | attribute | value                               |
      | SimpleProduct | name      | [string:a]                          |
      | SimpleProduct | price     | [float:2]                           |
      | GroupProduct  | name      | [string:a]                          |
      | GroupProduct  | active    | [string:f]                          |
      | GroupProduct  | launch    | [string:2012-06-03 00:00:00.000000] |