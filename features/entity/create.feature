Feature: create models with hydra attributes
  When create model with hydra attributes
  Then hydra attributes should be saved with default values

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name    | backend_type | default_value | white_list     |
      | code    | string       | [nil:]        | [boolean:true] |
      | price   | float        | 0             | [boolean:true] |
      | active  | boolean      | 0             | [boolean:true] |
      | info    | text         | [string:]     | [boolean:true] |
      | started | datetime     | 2012-01-01    | [boolean:true] |

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
      | code  | a      |
      | price | [nil:] |
    Then last created "Product" should have the following attributes:
      | code    | a                     |
      | price   | [nil:]                |
      | active  | [boolean:false]       |
      | info    | [string:]             |
      | started | [datetime:2012-01-01] |

  Scenario: create model hydra attributes
    Given create "Product" model with attributes as "rows_hash":
      | code    | a                     |
      | price   | 2                     |
      | active  | [boolean:true]        |
      | info    | b                     |
      | started | [datetime:2012-05-05] |

    Then last created "Product" should have the following attributes:
      | code    | a                     |
      | price   | [float:2]             |
      | active  | [boolean:true]        |
      | info    | b                     |
      | started | [datetime:2012-05-05] |