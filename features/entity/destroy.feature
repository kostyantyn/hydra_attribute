Feature: destroy model
  When destroy model
  Then all associated values should be deleted too

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name    | backend_type | default_value | white_list |
      | code    | string       |               | [bool:t]   |
      | info    | text         | [str:]        | [bool:t]   |
      | total   | integer      | 0             | [bool:t]   |
      | price   | float        | 0             | [bool:t]   |
      | active  | boolean      | 0             | [bool:t]   |
      | started | datetime     | 2012-01-01    | [bool:t]   |

  Scenario: destroy model
    Given create "Product" model with attributes as "hashes":
      | code | info | total | price | active | started    |
      | 1    | a    | 1     | 1.10  | 1      | 2012-01-01 |
      | 2    | b    | 2     | 1.20  | 1      | 2012-01-02 |
      | 3    | c    | 3     | 1.30  | 0      | 2012-01-03 |

    Then table "hydra_string_products" should have 3 records:
      | entity_id | hydra_attribute_id                        | value |
      | 1         | [eval:Product.hydra_attribute('code').id] | 1     |
      | 2         | [eval:Product.hydra_attribute('code').id] | 2     |
      | 3         | [eval:Product.hydra_attribute('code').id] | 3     |
    And table "hydra_text_products" should have 3 records:
      | entity_id | hydra_attribute_id                        | value |
      | 1         | [eval:Product.hydra_attribute('info').id] | a     |
      | 2         | [eval:Product.hydra_attribute('info').id] | b     |
      | 3         | [eval:Product.hydra_attribute('info').id] | c     |
    And table "hydra_integer_products" should have 3 records:
      | entity_id | hydra_attribute_id                         | value |
      | 1         | [eval:Product.hydra_attribute('total').id] | 1     |
      | 2         | [eval:Product.hydra_attribute('total').id] | 2     |
      | 3         | [eval:Product.hydra_attribute('total').id] | 3     |
    And table "hydra_float_products" should have 3 records:
      | entity_id | hydra_attribute_id                         | value |
      | 1         | [eval:Product.hydra_attribute('price').id] | 1.10  |
      | 2         | [eval:Product.hydra_attribute('price').id] | 1.20  |
      | 3         | [eval:Product.hydra_attribute('price').id] | 1.30  |
    And table "hydra_boolean_products" should have 3 records:
      | entity_id | hydra_attribute_id                          | value    |
      | 1         | [eval:Product.hydra_attribute('active').id] | [bool:t] |
      | 2         | [eval:Product.hydra_attribute('active').id] | [bool:t] |
      | 3         | [eval:Product.hydra_attribute('active').id] | [bool:f] |
    And table "hydra_datetime_products" should have 3 records:
      | entity_id | hydra_attribute_id                           | value             |
      | 1         | [eval:Product.hydra_attribute('started').id] | [date:2012-01-01] |
      | 2         | [eval:Product.hydra_attribute('started').id] | [date:2012-01-02] |
      | 3         | [eval:Product.hydra_attribute('started').id] | [date:2012-01-03] |

    Given select first "Product" record
    And destroy record

    Then table "hydra_string_products" should have 2 records:
      | entity_id | hydra_attribute_id                        | value |
      | 2         | [eval:Product.hydra_attribute('code').id] | 2     |
      | 3         | [eval:Product.hydra_attribute('code').id] | 3     |
    And table "hydra_text_products" should have 2 records:
      | entity_id | hydra_attribute_id                        | value |
      | 2         | [eval:Product.hydra_attribute('info').id] | b     |
      | 3         | [eval:Product.hydra_attribute('info').id] | c     |
    And table "hydra_integer_products" should have 2 records:
      | entity_id | hydra_attribute_id                         | value |
      | 2         | [eval:Product.hydra_attribute('total').id] | 2     |
      | 3         | [eval:Product.hydra_attribute('total').id] | 3     |
    And table "hydra_float_products" should have 2 records:
      | entity_id | hydra_attribute_id                         | value |
      | 2         | [eval:Product.hydra_attribute('price').id] | 1.20  |
      | 3         | [eval:Product.hydra_attribute('price').id] | 1.30  |
    And table "hydra_boolean_products" should have 2 records:
      | entity_id | hydra_attribute_id                          | value    |
      | 2         | [eval:Product.hydra_attribute('active').id] | [bool:t] |
      | 3         | [eval:Product.hydra_attribute('active').id] | [bool:f] |
    And table "hydra_datetime_products" should have 2 records:
      | entity_id | hydra_attribute_id                           | value             |
      | 2         | [eval:Product.hydra_attribute('started').id] | [date:2012-01-02] |
      | 3         | [eval:Product.hydra_attribute('started').id] | [date:2012-01-03] |

    Given select first "Product" record
    And destroy record

    Then table "hydra_string_products" should have 1 record:
      | entity_id | hydra_attribute_id                        | value |
      | 3         | [eval:Product.hydra_attribute('code').id] | 3     |
    And table "hydra_text_products" should have 1 record:
      | entity_id | hydra_attribute_id                        | value |
      | 3         | [eval:Product.hydra_attribute('info').id] | c     |
    And table "hydra_integer_products" should have 1 record:
      | entity_id | hydra_attribute_id                         | value |
      | 3         | [eval:Product.hydra_attribute('total').id] | 3     |
    And table "hydra_float_products" should have 1 record:
      | entity_id | hydra_attribute_id                         | value |
      | 3         | [eval:Product.hydra_attribute('price').id] | 1.30  |
    And table "hydra_boolean_products" should have 1 record:
      | entity_id | hydra_attribute_id                          | value    |
      | 3         | [eval:Product.hydra_attribute('active').id] | [bool:f] |
    And table "hydra_datetime_products" should have 1 record:
      | entity_id | hydra_attribute_id                           | value             |
      | 3         | [eval:Product.hydra_attribute('started').id] | [date:2012-01-03] |

    Given select first "Product" record
    And destroy record

    Then table "hydra_string_products" should have 0 records
    And table "hydra_text_products" should have 0 records
    And table "hydra_integer_products" should have 0 records
    And table "hydra_float_products" should have 0 records
    And table "hydra_boolean_products" should have 0 records
    And table "hydra_datetime_products" should have 0 records