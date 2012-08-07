Feature: Migration to hydra attributes
  We should be able to create all necessary EAV tables as well as migrate existing to them

Background: create separate database connection pool
  Given create connection

Scenario: create and drop hydra entity
  When create hydra entity "wheels"
  Then should have the following 8 tables:
    | tables                |
    | wheels                |
    | hydra_attributes      |
    | hydra_string_wheels   |
    | hydra_text_wheels     |
    | hydra_float_wheels    |
    | hydra_integer_wheels  |
    | hydra_boolean_wheels  |
    | hydra_datetime_wheels |
  And table "wheels" should have the following columns:
    | name        | type             | limit  | default | null            | precision | scale  |
    | [string:id] | [symbol:integer] | [nil:] | [nil:]  | [boolean:false] | [nil:]    | [nil:] |
  And table "hydra_attributes" should have the following columns:
    | name                   | type              | limit         | default         | null            | precision | scale  |
    | [string:id]            | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:entity_type]   | [symbol:string]   | [integer:32]  | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:name]          | [symbol:string]   | [integer:32]  | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:backend_type]  | [symbol:string]   | [integer:16]  | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:default_value] | [symbol:string]   | [integer:255] | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:white_list]    | [symbol:boolean]  | [nil:]        | [boolean:false] | [boolean:false] | [nil:]    | [nil:] |
    | [string:created_at]    | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:updated_at]    | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
  And table "hydra_attributes" should have the following indexes:
    | name                   | columns                  | unique         |
    | hydra_attributes_index | [array:entity_type,name] | [boolean:true] |
  And table "hydra_string_wheels" should have the following columns:
    | name                        | type              | limit         | default         | null            | precision | scale  |
    | [string:id]                 | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:entity_id]          | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:hydra_attribute_id] | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:value]              | [symbol:string]   | [integer:255] | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:created_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:updated_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
  And table "hydra_string_wheels" should have the following indexes:
    | name                      | columns                              | unique         |
    | hydra_string_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
  And table "hydra_text_wheels" should have the following columns:
    | name                        | type              | limit         | default         | null            | precision | scale  |
    | [string:id]                 | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:entity_id]          | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:hydra_attribute_id] | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:value]              | [symbol:text]     | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:created_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:updated_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
  And table "hydra_text_wheels" should have the following indexes:
    | name                    | columns                              | unique         |
    | hydra_text_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
  And table "hydra_integer_wheels" should have the following columns:
    | name                        | type              | limit         | default         | null            | precision | scale  |
    | [string:id]                 | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:entity_id]          | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:hydra_attribute_id] | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:value]              | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:created_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:updated_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
  And table "hydra_integer_wheels" should have the following indexes:
    | name                    | columns                                 | unique         |
    | hydra_integer_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
  And table "hydra_float_wheels" should have the following columns:
    | name                        | type              | limit         | default         | null            | precision | scale  |
    | [string:id]                 | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:entity_id]          | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:hydra_attribute_id] | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:value]              | [symbol:float]    | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:created_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:updated_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
  And table "hydra_float_wheels" should have the following indexes:
    | name                    | columns                               | unique         |
    | hydra_float_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
  And table "hydra_boolean_wheels" should have the following columns:
    | name                        | type              | limit         | default         | null            | precision | scale  |
    | [string:id]                 | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:entity_id]          | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:hydra_attribute_id] | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:value]              | [symbol:boolean]  | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:created_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:updated_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
  And table "hydra_boolean_wheels" should have the following indexes:
    | name                       | columns                              | unique         |
    | hydra_boolean_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |
  And table "hydra_datetime_wheels" should have the following columns:
    | name                        | type              | limit         | default         | null            | precision | scale  |
    | [string:id]                 | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:entity_id]          | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:hydra_attribute_id] | [symbol:integer]  | [nil:]        | [nil:]          | [boolean:false] | [nil:]    | [nil:] |
    | [string:value]              | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:created_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
    | [string:updated_at]         | [symbol:datetime] | [nil:]        | [nil:]          | [boolean:true]  | [nil:]    | [nil:] |
  And table "hydra_datetime_wheels" should have the following indexes:
    | name                        | columns                              | unique         |
    | hydra_datetime_wheels_index | [array:entity_id,hydra_attribute_id] | [boolean:true] |

  When create hydra entity "cars"
  Then should have the following 15 tables:
    | tables                |
    | wheels                |
    | hydra_attributes      |
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
  Then should have the following 8 tables:
    | tables                |
    | hydra_attributes      |
    | cars                  |
    | hydra_string_cars     |
    | hydra_text_cars       |
    | hydra_float_cars      |
    | hydra_integer_cars    |
    | hydra_boolean_cars    |
    | hydra_datetime_cars   |

  When drop hydra entity "cars"
  Then should not have any tables
