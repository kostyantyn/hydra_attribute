Feature: create models with hydra attributes
  When create model with hydra attributes
  Then hydra attributes should be saved with default values

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name             | backend_type      | default_value       | white_list     |
      | [string:code]    | [string:string]   | [nil:]              | [boolean:true] |
      | [string:price]   | [string:float]    | [string:0]          | [boolean:true] |
      | [string:active]  | [string:boolean]  | [string:0]          | [boolean:true] |
      | [string:info]    | [string:text]     | [string:]           | [boolean:true] |
      | [string:started] | [string:datetime] | [string:2012-01-01] | [boolean:true] |

  Scenario: create model without hydra attributes
    Given create "Product" model
    Then last created "Product" should have the following attributes:
      | code    | [nil:]                |
      | price   | [float:0]             |
      | active  | [boolean:false]       |
      | info    | [string:]             |
      | started | [datetime:2012-01-01] |

  Scenario: create model with several hydra attributes
    Given create "Product" model with attributes as "rows_hash":
      | code  | [string:a] |
      | price | [nil:]     |
    Then last created "Product" should have the following attributes:
      | code    | [string:a]            |
      | price   | [nil:]                |
      | active  | [boolean:false]       |
      | info    | [string:]             |
      | started | [datetime:2012-01-01] |

  Scenario: create model hydra attributes
    Given create "Product" model with attributes as "rows_hash":
      | code    | [string:a]            |
      | price   | [string:2]            |
      | active  | [boolean:true]        |
      | info    | [string:b]            |
      | started | [datetime:2012-05-05] |

    Then last created "Product" should have the following attributes:
      | code    | [string:a]            |
      | price   | [float:2]             |
      | active  | [boolean:true]        |
      | info    | [string:b]            |
      | started | [datetime:2012-05-05] |