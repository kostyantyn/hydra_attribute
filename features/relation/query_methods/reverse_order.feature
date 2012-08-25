Feature: reverse order relation object
  When reverse order by hydra attribute
  Then relation object should reverse order of hydra attribute. ASC to DESC and vise versa

  Background: create hydra attributes
    Given create hydra attributes for "Product" with role "admin" as "hashes":
      | name  | backend_type | white_list |
      | code  | integer      | [bool:t]   |
      | state | integer      | [bool:t]   |
      | title | string       | [bool:t]   |

  Scenario Outline: reverse order
    Given create "Product" model with attributes as "hashes":
      | code | state | title |
      | 1    | 3     | a     |
      | 2    | 2     | b     |
      | 3    | 1     | c     |
    When order "Product" records by "<order>"
    And reverse order records
    Then total records should be "3"
    And "first" record should have "<first>"
    And "last" record should have "<last>"

    Scenarios: conditions
      | order | first        | last         |
      | code  | code=[int:3] | code=[int:1] |
      | state | code=[int:1] | code=[int:3] |
      | title | code=[int:3] | code=[int:1] |

