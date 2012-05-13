Feature: define hydra attributes
  Models should respond to hydra attributes

  Model should respond to hydra attributes if they are described in the class.
  Model should not respond to hydra attribute if it isn't described in it class.

  Background: create models and describe hydra attributes
    Given removed constants if they exist:
      | name          |
      | GroupProduct  |
      | SimpleProduct |
      | Product       |
    And create model class "Product"
    And create model class "SimpleProduct" as "Product" with hydra attributes:
      | type   | name  |
      | string | code  |
      | float  | price |
    And create model class "GroupProduct" as "Product" with hydra attributes:
      | type    | name   |
      | float   | price  |
      | string  | title  |
      | boolean | active |

  Scenario Outline: models should respond to hydra attributes
    Then model "<model>" should "<respond>" to "<attributes>"

    Scenarios: model SimpleProduct should respond to own hydra attributes
      | model         | respond | attributes          |
      | SimpleProduct | should  | code code= code?    |
      | SimpleProduct | should  | price price= price? |

    Scenarios: model SimpleProduct should not respond to other hydra attributes
      | model         | respond    | attributes             |
      | SimpleProduct | should_not | title title= title?    |
      | SimpleProduct | should_not | active active= active? |

    Scenarios: model GroupProduct should respond to own hydra attributes
      | model        | respond | attributes             |
      | GroupProduct | should  | price price= price?    |
      | GroupProduct | should  | title title= title?    |
      | GroupProduct | should  | active active= active? |

    Scenarios: model GroupProduct should not respond to other hydra attributes
      | model        | respond    | attributes       |
      | GroupProduct | should_not | code code= code? |