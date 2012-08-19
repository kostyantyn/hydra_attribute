Feature: new entity
  Given new entity should respond to hydra attributes which are saved in hydra_attributes table

  When hydra attribute was created with white_list flag
  Then it should be allowed through mass-assignment for new entity

  When hydra_set_id was passed to the new entity
  Then entity should respond only to hydra attributes which were added to this hydra set
  And  entity attribute list should include only attributes from hydra set
  And  HydraAttribute::MissingAttributeInHydraSetError error should be risen when we call attribute method and this attribute doesn't exist in hydra set

  Scenario Outline: models should respond to hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list      |
      | code  | string       | [boolean:true]  |
      | price | float        | [boolean:false] |
    Then model "<model>" <action> respond to "<attributes>"

    Scenarios: hydra attributes
      | model   | action | attributes             |
      | Product | should | code                   |
      | Product | should | code=                  |
      | Product | should | code?                  |
      | Product | should | code_before_type_cast  |
      | Product | should | code_changed?          |
      | Product | should | code_change            |
      | Product | should | code_will_change!      |
      | Product | should | code_was               |
      | Product | should | reset_code!            |
      | Product | should | price                  |
      | Product | should | price=                 |
      | Product | should | price?                 |
      | Product | should | price_before_type_cast |
      | Product | should | price_changed?         |
      | Product | should | price_change           |
      | Product | should | price_will_change!     |
      | Product | should | price_was              |
      | Product | should | reset_price!           |

  Scenario: model should have appropriate hydra attributes in white list
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list      |
      | code  | string       | [boolean:true]  |
      | price | float        | [boolean:false] |
    # imitate initialization model class with already created hydra attributes
    When redefine "Product" class to use hydra attributes
    Then class "Product" should have "code" in white list
    And class "Product" should not have "price" in white list

  Scenario: set hydra_set_id to the new entity
    Given create hydra sets for "Product" as "hashes":
      | name    |
      | Default |
      | General |
    And create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list     |
      | code  | string       | [boolean:true] |
      | title | string       | [boolean:true] |
      | price | float        | [boolean:true] |
      | total | integer      | [boolean:true] |
    And add "Product" hydra attributes to hydra set:
      | hydra attribute name | hydra set name          |
      | code                 | [array:Default]         |
      | title                | [array:Default,General] |
      | price                | [array:General]         |

    When build "Product" model:
      | hydra_set_id | [string:[eval:Product.hydra_sets.find_by_name('Default').id]] |
    Then model should respond to "code title"
    And model should not respond to "price total"

    When build "Product" model:
      | hydra_set_id | [string:[eval:Product.hydra_sets.find_by_name('General').id]] |
    Then model should not respond to "code total"
    And model should respond to "title price"

    When build "Product" model
    Then model should respond to "code title price total"

  Scenario: attach and detach hydra set to the same entity
    Given create hydra sets for "Product" as "hashes":
      | name    |
      | Default |
      | General |
    And create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list     |
      | title | string       | [boolean:true] |
      | code  | string       | [boolean:true] |
      | total | integer      | [boolean:true] |
      | price | float        | [boolean:true] |
    And add "Product" hydra attributes to hydra set:
      | hydra attribute name | hydra set name          |
      | title                | [array:Default]         |
      | code                 | [array:Default,General] |
      | total                | [array:General]         |

    When build "Product" model
    Then model should respond to "title code total price"
    And  model attributes should include "title code total price"
    And  error "HydraAttribute::MissingAttributeInHydraSetError" should not be risen when methods "title code total price" are called

    When set "hydra_set_id" to "[eval:Product.hydra_sets.find_by_name('Default').id]"
    Then model should respond to "title code"
    And  model should not respond to "total price"
    And  model attributes should include "title code"
    And  model attributes should not include "total price"
    And  error "HydraAttribute::MissingAttributeInHydraSetError" should be risen when methods "total price" are called
    And  error "HydraAttribute::MissingAttributeInHydraSetError" should not be risen when methods "title code" are called

    When set "hydra_set_id" to "[eval:Product.hydra_sets.find_by_name('General').id]"
    Then model should respond to "code total"
    And  model should not respond to "title price"
    And  model attributes should include "code total"
    And  model attributes should not include "title price"
    And  error "HydraAttribute::MissingAttributeInHydraSetError" should be risen when methods "title price" are called
    And  error "HydraAttribute::MissingAttributeInHydraSetError" should not be risen when methods "code total" are called

    When set "hydra_set_id" to "[nil:]"
    Then model should respond to "title code total price"
    And  model attributes should include "title code total price"
    And  error "HydraAttribute::MissingAttributeInHydraSetError" should not be risen when methods "title code total price" are called