Feature: create model
  Model should be created with typecast hydra attributes.

  Background: create models and describe hydra attributes
    Given create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type   | name  |
      | string | code  |
      | float  | price |
    And create model class "GroupProduct" as "Product" with hydra attributes:
      | type    | name   |
      | float   | price  |
      | string  | title  |
      | boolean | active |

  Scenario Outline: create model with hydra attributes
    Given create model "<model>" with attributes "<attributes>"
    Then it should have typecast attributes "<typecast_attributes>"

    Scenarios:
      | model         | attributes                                            | typecast_attributes                                    |
      | SimpleProduct | code=[integer:1] price=[string:2.75]                  | code=[string:1] price=[float:2.75]                     |
      | GroupProduct  | price=[string:2] title=[integer:1] active=[integer:1] | price=[float:2] title=[string:1] active=[boolean:true] |
      | GroupProduct  | active=[integer:0]                                    | price=[nil:] title=[nil:] active=[boolean:false]       |
