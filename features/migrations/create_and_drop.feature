Feature: create and drop hydra EAV stack
  When create hydra entity
  Then all necessary tables with indexes should be created

  When drop hydra entity
  Then all necessary tables should be dropped

  Background: create migration with separate connection
    Given create connection

  Scenario: create and drop hydra entity
    When create hydra entity "wheels"
    Then should have the following 10 tables:
      | tables                |
      | wheels                |
      | hydra_attributes      |
      | hydra_sets            |
      | hydra_attribute_sets  |
      | hydra_string_wheels   |
      | hydra_text_wheels     |
      | hydra_float_wheels    |
      | hydra_integer_wheels  |
      | hydra_boolean_wheels  |
      | hydra_datetime_wheels |
    And table "wheels" should have the following columns:
      | name         | type          | limit  | default | null     | precision | scale  |
      | id           | [sym:integer] | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_set_id | [sym:integer] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "wheels" should have the following indexes:
      | name                      | columns              | unique   |
      | wheels_hydra_set_id_index | [array:hydra_set_id] | [bool:f] |
    And table "hydra_attributes" should have the following columns:
      | name          | type           | limit     | default  | null     | precision | scale  |
      | id            | [sym:integer]  | [nil:]    | [nil:]   | [bool:f] | [nil:]    | [nil:] |
      | entity_type   | [sym:string]   | [int:32]  | [nil:]   | [bool:f] | [nil:]    | [nil:] |
      | name          | [sym:string]   | [int:32]  | [nil:]   | [bool:f] | [nil:]    | [nil:] |
      | backend_type  | [sym:string]   | [int:16]  | [nil:]   | [bool:f] | [nil:]    | [nil:] |
      | default_value | [sym:string]   | [int:255] | [nil:]   | [bool:t] | [nil:]    | [nil:] |
      | white_list    | [sym:boolean]  | [nil:]    | [bool:f] | [bool:f] | [nil:]    | [nil:] |
      | created_at    | [sym:datetime] | [nil:]    | [nil:]   | [bool:t] | [nil:]    | [nil:] |
      | updated_at    | [sym:datetime] | [nil:]    | [nil:]   | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_attributes" should have the following indexes:
      | name                   | columns                  | unique   |
      | hydra_attributes_index | [array:entity_type,name] | [bool:t] |
    And table "hydra_sets" should have the following columns:
      | name        | type           | limit    | default | null     | precision | scale  |
      | id          | [sym:integer]  | [nil:]   | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | entity_type | [sym:string]   | [int:32] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | name        | [sym:string]   | [int:32] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | created_at  | [sym:datetime] | [nil:]   | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | updated_at  | [sym:datetime] | [nil:]   | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_sets" should have the following indexes:
      | name             | columns                  | unique   |
      | hydra_sets_index | [array:entity_type,name] | [bool:t] |
    And table "hydra_attribute_sets" should have the following columns:
      | name               | type          | limit  | default | null     | precision | scale  |
      | hydra_attribute_id | [sym:integer] | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_set_id       | [sym:integer] | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
    And table "hydra_attribute_sets" should have the following indexes:
      | name                       | columns                                 | unique   |
      | hydra_attribute_sets_index | [array:hydra_attribute_id,hydra_set_id] | [bool:t] |
    And table "hydra_string_wheels" should have the following columns:
      | name               | type           | limit     | default | null     | precision | scale  |
      | id                 | [sym:integer]  | [nil:]    | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | entity_id          | [sym:integer]  | [nil:]    | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_attribute_id | [sym:integer]  | [nil:]    | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | value              | [sym:string]   | [int:255] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | created_at         | [sym:datetime] | [nil:]    | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | updated_at         | [sym:datetime] | [nil:]    | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_string_wheels" should have the following indexes:
      | name                      | columns                              | unique   |
      | hydra_string_wheels_index | [array:entity_id,hydra_attribute_id] | [bool:t] |
    And table "hydra_text_wheels" should have the following columns:
      | name               | type           | limit  | default | null     | precision | scale  |
      | id                 | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | entity_id          | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_attribute_id | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | value              | [sym:text]     | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | created_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | updated_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_text_wheels" should have the following indexes:
      | name                    | columns                              | unique   |
      | hydra_text_wheels_index | [array:entity_id,hydra_attribute_id] | [bool:t] |
    And table "hydra_integer_wheels" should have the following columns:
      | name               | type           | limit  | default | null     | precision | scale  |
      | id                 | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | entity_id          | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_attribute_id | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | value              | [sym:integer]  | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | created_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | updated_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_integer_wheels" should have the following indexes:
      | name                       | columns                              | unique   |
      | hydra_integer_wheels_index | [array:entity_id,hydra_attribute_id] | [bool:t] |
    And table "hydra_float_wheels" should have the following columns:
      | name               | type           | limit  | default | null     | precision | scale  |
      | id                 | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | entity_id          | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_attribute_id | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | value              | [sym:float]    | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | created_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | updated_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_float_wheels" should have the following indexes:
      | name                     | columns                              | unique   |
      | hydra_float_wheels_index | [array:entity_id,hydra_attribute_id] | [bool:t] |
    And table "hydra_boolean_wheels" should have the following columns:
      | name               | type           | limit  | default | null     | precision | scale  |
      | id                 | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | entity_id          | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_attribute_id | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | value              | [sym:boolean]  | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | created_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | updated_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_boolean_wheels" should have the following indexes:
      | name                       | columns                              | unique   |
      | hydra_boolean_wheels_index | [array:entity_id,hydra_attribute_id] | [bool:t] |
    And table "hydra_datetime_wheels" should have the following columns:
      | name               | type           | limit  | default | null     | precision | scale  |
      | id                 | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | entity_id          | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | hydra_attribute_id | [sym:integer]  | [nil:] | [nil:]  | [bool:f] | [nil:]    | [nil:] |
      | value              | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | created_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
      | updated_at         | [sym:datetime] | [nil:] | [nil:]  | [bool:t] | [nil:]    | [nil:] |
    And table "hydra_datetime_wheels" should have the following indexes:
      | name                        | columns                              | unique   |
      | hydra_datetime_wheels_index | [array:entity_id,hydra_attribute_id] | [bool:t] |

    When create hydra entity "cars"
    Then should have the following 17 tables:
      | tables                |
      | wheels                |
      | hydra_attributes      |
      | hydra_sets            |
      | hydra_attribute_sets  |
      | hydra_string_wheels   |
      | hydra_text_wheels     |
      | hydra_float_wheels    |
      | hydra_integer_wheels  |
      | hydra_boolean_wheels  |
      | hydra_datetime_wheels |
      | cars                  |
      | hydra_string_cars     |
      | hydra_text_cars       |
      | hydra_float_cars      |
      | hydra_integer_cars    |
      | hydra_boolean_cars    |
      | hydra_datetime_cars   |

    When drop hydra entity "wheels"
    Then should have the following 10 tables:
      | tables               |
      | hydra_attributes     |
      | hydra_sets           |
      | hydra_attribute_sets |
      | cars                 |
      | hydra_string_cars    |
      | hydra_text_cars      |
      | hydra_float_cars     |
      | hydra_integer_cars   |
      | hydra_boolean_cars   |
      | hydra_datetime_cars  |

    When drop hydra entity "cars"
    Then should not have any tables
