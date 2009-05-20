Feature: Well-formedness
  Ill-formedness of a document should be reported.

  Scenario Outline: document formedness
    Given I submit a <state>-formed document
    When I press validate
    Then a result document should be returned
    And it should contain <quantity> formedness errors

    Examples:
        | state | quantity |
        | well  | no       |
        | ill   | some     |
