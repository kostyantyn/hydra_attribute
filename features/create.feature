Feature: create models with hydra attributes
  When create model with hydra attributes
  Then hydra attributes should be saved with default values

  Background: create hydra attributes
    Given create "HydraAttribute::HydraAttribute" models with attributes as "hashes":
      | entity_type | name    | backend_type | default_value       |
      | Product     | code    | string       | [nil:]              |
      | Product     | price   | float        | [string:0]          |
      | Product     | active  | boolean      | [string:0]          |
      | Product     | info    | text         | [string:]           |
      | Product     | started | datetime     | [string:2012-01-01] |

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