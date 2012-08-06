Feature: Migration to hydra attributes
  We should be able to create all necessary EAV tables as well as migrate existing to them

Background: create separate database connection pool
  Given create connection

Scenario: create hydra attributes
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