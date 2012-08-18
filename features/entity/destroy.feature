Feature: destroy model
  When destroy model
  Then all associated values should be deleted too

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name             | backend_type      | default_value       | white_list     |
      | [string:code]    | [string:string]   | [nil:]              | [boolean:true] |
      | [string:price]   | [string:float]    | [string:0]          | [boolean:true] |
      | [string:active]  | [string:boolean]  | [string:0]          | [boolean:true] |
      | [string:info]    | [string:text]     | [string:]           | [boolean:true] |
      | [string:started] | [string:datetime] | [string:2012-01-01] | [boolean:true] |

  Scenario: destroy model
    Given create "Product" model with attributes as "hashes":
      | code       | price     | active         | info       | started             |
      | [string:1] | [float:1] | [boolean:true] | [string:a] | [string:2012-01-01] |
      | [string:2] | [float:2] | [boolean:true] | [string:b] | [string:2012-01-02] |
      | [string:3] | [float:3] | [boolean:true] | [string:c] | [string:2012-01-03] |
      | [string:4] | [float:4] | [boolean:true] | [string:d] | [string:2012-01-04] |
      | [string:5] | [float:5] | [boolean:true] | [string:e] | [string:2012-01-05] |

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