Feature: create models with hydra attributes
  When create model with hydra attributes
  Then hydra attributes should be saved with default values

  When hydra set is specified
  Then only attributes from this hydra set should be saved

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

  Scenario: create model with specified hydra set
    Given create hydra sets for "Product" as "hashes":
      | name    |
      | Default |
      | General |
    And add "Product" hydra attributes to hydra set:
      | hydra attribute name | hydra set name          |
      | code                 | [array:Default]         |
      | price                | [array:Default]         |
      | active               | [array:Default,General] |
      | info                 | [array:General]         |

    When create "Product" model with attributes as "rows_hash":
      | hydra_set_id | [eval:Product.hydra_sets.find_by_name('Default').id] |
    Then table "hydra_string_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                      |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('code').id] |
    And table "hydra_float_products" should have 1 record:
      | entity_id              | hydra_attribute_id                                       |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('price').id] |
    And table "hydra_boolean_products" should have 1 records:
      | entity_id              | hydra_attribute_id                                        |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('active').id] |
    And table "hydra_text_products" should have 0 records
    And table "hydra_integer_products" should have 0 records
    And table "hydra_datetime_products" should have 0 records

    When create "Product" model with attributes as "rows_hash":
      | hydra_set_id | [eval:Product.hydra_sets.find_by_name('General').id] |
    And table "hydra_boolean_products" should have 2 records:
      | entity_id              | hydra_attribute_id                                        |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('active').id] |
    And table "hydra_text_products" should have 1 records:
      | entity_id              | hydra_attribute_id                                      |
      | [eval:Product.last.id] | [eval:Product.hydra_attributes.find_by_name('info').id] |
    And table "hydra_string_products" should have 1 record
    And table "hydra_float_products" should have 1 record
    And table "hydra_integer_products" should have 0 records
    And table "hydra_datetime_products" should have 0 records
