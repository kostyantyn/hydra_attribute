Feature: migrate to and rollback from hydra EAV stack
  When migrate existing table to EAV
  Then all additional tables with indexes should be created

  When rollback from hydra entity
  Then all hydra attribute tables should be dropped
  And hydra_set_id column from entity table should be removed
  But main entity table should be kept

  Background: create migration with separate connection
    Given create connection

  Scenario: migrate existing tables to hydra and then rollback them
    When create table "wheels"
    And create table "cars"
    Then should have the following 2 tables:
      | tables |
      | wheels |
      | cars   |
    And table "wheels" should have the following columns:
      | name | type             | limit  | default | null            | precision | scale  |
      | id   | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
    And table "cars" should have the following columns:
      | name | type             | limit  | default | null            | precision | scale  |
      | id   | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |

    When migrate to hydra entity "wheels"
    Then should have the following 11 tables:
      | tables                |
      | wheels                |
      | cars                  |
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
      | name         | type             | limit  | default | null            | precision | scale  |
      | id           | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_set_id | [symbol:integer] | [nil:] | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "wheels" should have the following indexes:
      | name                      | columns              | unique          |
      | wheels_hydra_set_id_index | [array:hydra_set_id] | [boolean:false] |
    And table "cars" should have the following columns:
      | name | type             | limit  | default | null            | precision | scale  |
      | id   | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
    And table "hydra_attributes" should have the following columns:
      | name          | type              | limit         | default         | null            | precision | scale  |
      | id            | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
      | entity_type   | [symbol:string]   | [integer:32]  | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
      | name          | [symbol:string]   | [integer:32]  | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
      | backend_type  | [symbol:string]   | [integer:16]  | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
      | default_value | [symbol:string]   | [integer:255] | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
      | white_list    | [symbol:boolean]  | [nil:]        | [boolean:false] | [boolean:false] | [nil:]    | [nil:] |
      | created_at    | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at    | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_attributes" should have the following indexes:
      | name                   | columns                  | unique         |
      | hydra_attributes_index | [array:entity_type,name] | [boolean:true] |
    And table "hydra_sets" should have the following columns:
      | name          | type              | limit         | default | null            | precision | scale  |
      | id            | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | entity_type   | [symbol:string]   | [integer:32]  | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | name          | [symbol:string]   | [integer:32]  | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | created_at    | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at    | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_sets" should have the following indexes:
      | name             | columns                  | unique         |
      | hydra_sets_index | [array:entity_type,name] | [boolean:true] |
    And table "hydra_attribute_sets" should have the following columns:
      | name               | type              | limit  | default | null            | precision | scale  |
      | hydra_attribute_id | [symbol:integer]  | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_set_id       | [symbol:integer]  | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
    And table "hydra_attribute_sets" should have the following indexes:
      | name                       | columns                                 | unique         |
      | hydra_attribute_sets_index | [array:hydra_attribute_id,hydra_set_id] | [boolean:true] |
    And table "hydra_string_wheels" should have the following columns:
      | name               | type              | limit         | default | null            | precision | scale  |
      | id                 | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | entity_id          | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_attribute_id | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | value              | [symbol:string]   | [integer:255] | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | created_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_string_wheels" should have the following indexes:
      | name                      | columns                              | unique         |
      | hydra_string_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
    And table "hydra_text_wheels" should have the following columns:
      | name               | type              | limit         | default | null            | precision | scale  |
      | id                 | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | entity_id          | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_attribute_id | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | value              | [symbol:text]     | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | created_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_text_wheels" should have the following indexes:
      | name                    | columns                              | unique         |
      | hydra_text_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
    And table "hydra_integer_wheels" should have the following columns:
      | name               | type              | limit         | default | null            | precision | scale  |
      | id                 | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | entity_id          | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_attribute_id | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | value              | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | created_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_integer_wheels" should have the following indexes:
      | name                       | columns                              | unique         |
      | hydra_integer_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
    And table "hydra_float_wheels" should have the following columns:
      | name               | type              | limit         | default | null            | precision | scale  |
      | id                 | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | entity_id          | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_attribute_id | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | value              | [symbol:float]    | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | created_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_float_wheels" should have the following indexes:
      | name                     | columns                              | unique         |
      | hydra_float_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
    And table "hydra_boolean_wheels" should have the following columns:
      | name               | type              | limit         | default | null            | precision | scale  |
      | id                 | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | entity_id          | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_attribute_id | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | value              | [symbol:boolean]  | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | created_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_boolean_wheels" should have the following indexes:
      | name                       | columns                              | unique         |
      | hydra_boolean_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
    And table "hydra_datetime_wheels" should have the following columns:
      | name               | type              | limit         | default | null            | precision | scale  |
      | id                 | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | entity_id          | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_attribute_id | [symbol:integer]  | [nil:]        | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | value              | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | created_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
      | updated_at         | [symbol:datetime] | [nil:]        | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "hydra_datetime_wheels" should have the following indexes:
      | name                        | columns                              | unique         |
      | hydra_datetime_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |

    When migrate to hydra entity "cars"
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
    And table "cars" should have the following columns:
      | name         | type             | limit  | default | null            | precision | scale  |
      | id           | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_set_id | [symbol:integer] | [nil:] | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "cars" should have the following indexes:
      | name                    | columns              | unique          |
      | cars_hydra_set_id_index | [array:hydra_set_id] | [boolean:false] |

    When rollback from hydra entity "wheels"
    Then should have the following 11 tables:
      | tables                |
      | wheels                |
      | hydra_attributes      |
      | hydra_sets            |
      | hydra_attribute_sets  |
      | cars                  |
      | hydra_string_cars     |
      | hydra_text_cars       |
      | hydra_float_cars      |
      | hydra_integer_cars    |
      | hydra_boolean_cars    |
      | hydra_datetime_cars   |
    And table "wheels" should have the following columns:
      | name | type             | limit  | default | null            | precision | scale  |
      | id   | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
    And table "cars" should have the following columns:
      | name         | type             | limit  | default | null            | precision | scale  |
      | id           | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
      | hydra_set_id | [symbol:integer] | [nil:] | [nil:]  | [boolean:true]  | [nil:]    | [nil:] |
    And table "cars" should have the following indexes:
      | name                    | columns              | unique          |
      | cars_hydra_set_id_index | [array:hydra_set_id] | [boolean:false] |

    When rollback from hydra entity "cars"
    Then should have the following 2 tables:
      | tables |
      | wheels |
      | cars   |
    And table "wheels" should have the following columns:
      | name      | type             | limit  | default | null            | precision | scale  |
      | string:id | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
    And table "cars" should have the following columns:
      | name | type             | limit  | default | null            | precision | scale  |
      | id   | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
