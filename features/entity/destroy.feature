Feature: destroy model
  When destroy model
  Then all associated values should be deleted too

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name    | backend_type | default_value | white_list     |
      | code    | string       | [nil:]        | [boolean:true] |
      | price   | float        | 0             | [boolean:true] |
      | active  | boolean      | 0             | [boolean:true] |
      | info    | text         | [string:]     | [boolean:true] |
      | started | datetime     | 2012-01-01    | [boolean:true] |

  Scenario: destroy model
    Given create "Product" model with attributes as "hashes":
      | code | price | active | info | started    |
      | 1    | 1     | 1      | a    | 2012-01-01 |
      | 2    | 2     | 1      | b    | 2012-01-02 |
      | 3    | 3     | 1      | c    | 2012-01-03 |
      | 4    | 4     | 1      | d    | 2012-01-04 |
      | 5    | 5     | 1      | e    | 2012-01-05 |

    When select first "HydraAttribute::HydraStringProduct" record
    Then record read attribute "value" and value should be "[string:1]"
    When select first "HydraAttribute::HydraFloatProduct" record
    Then record read attribute "value" and value should be "[float:1]"
    When select first "HydraAttribute::HydraBooleanProduct" record
    Then record read attribute "value" and value should be "[boolean:true]"
    When select first "HydraAttribute::HydraTextProduct" record
    Then record read attribute "value" and value should be "[string:a]"
    When select first "HydraAttribute::HydraDatetimeProduct" record
    Then record read attribute "value" and value should be "[string:2012-01-01]"

    Given select first "Product" record
    And destroy record

    When select first "HydraAttribute::HydraStringProduct" record
    Then record read attribute "value" and value should be "[string:2]"
    When select first "HydraAttribute::HydraFloatProduct" record
    Then record read attribute "value" and value should be "[float:2]"
    When select first "HydraAttribute::HydraBooleanProduct" record
    Then record read attribute "value" and value should be "[boolean:true]"
    When select first "HydraAttribute::HydraTextProduct" record
    Then record read attribute "value" and value should be "[string:b]"
    When select first "HydraAttribute::HydraDatetimeProduct" record
    Then record read attribute "value" and value should be "[string:2012-01-02]"

    Given select first "Product" record
    And destroy record

    When select first "HydraAttribute::HydraStringProduct" record
    Then record read attribute "value" and value should be "[string:3]"
    When select first "HydraAttribute::HydraFloatProduct" record
    Then record read attribute "value" and value should be "[float:3]"
    When select first "HydraAttribute::HydraBooleanProduct" record
    Then record read attribute "value" and value should be "[boolean:true]"
    When select first "HydraAttribute::HydraTextProduct" record
    Then record read attribute "value" and value should be "[string:c]"
    When select first "HydraAttribute::HydraDatetimeProduct" record
    Then record read attribute "value" and value should be "[string:2012-01-03]"

    Given select first "Product" record
    And destroy record

    When select first "HydraAttribute::HydraStringProduct" record
    Then record read attribute "value" and value should be "[string:4]"
    When select first "HydraAttribute::HydraFloatProduct" record
    Then record read attribute "value" and value should be "[float:4]"
    When select first "HydraAttribute::HydraBooleanProduct" record
    Then record read attribute "value" and value should be "[boolean:true]"
    When select first "HydraAttribute::HydraTextProduct" record
    Then record read attribute "value" and value should be "[string:d]"
    When select first "HydraAttribute::HydraDatetimeProduct" record
    Then record read attribute "value" and value should be "[string:2012-01-04]"

    Given select first "Product" record
    And destroy record

    When select first "HydraAttribute::HydraStringProduct" record
    Then record read attribute "value" and value should be "[string:5]"
    When select first "HydraAttribute::HydraFloatProduct" record
    Then record read attribute "value" and value should be "[float:5]"
    When select first "HydraAttribute::HydraBooleanProduct" record
    Then record read attribute "value" and value should be "[boolean:true]"
    When select first "HydraAttribute::HydraTextProduct" record
    Then record read attribute "value" and value should be "[string:e]"
    When select first "HydraAttribute::HydraDatetimeProduct" record
    Then record read attribute "value" and value should be "[string:2012-01-05]"

    Given select first "Product" record
    And destroy record

    When select first "HydraAttribute::HydraStringProduct" record
    Then record should be nil
    When select first "HydraAttribute::HydraFloatProduct" record
    Then record should be nil
    When select first "HydraAttribute::HydraBooleanProduct" record
    Then record should be nil
    When select first "HydraAttribute::HydraTextProduct" record
    Then record should be nil
    When select first "HydraAttribute::HydraDatetimeProduct" record
    Then record should be nil