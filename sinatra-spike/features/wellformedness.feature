Feature: Well-formedness
  Ill-formedness of a document should be reported.

  Scenario Outline: document formedness
    Given I submit a <state> document
    When I press validate
    Then a result document should be returned
    And it should contain <quantity> formedness errors

    Examples:
        | state   | quantity |
        | valid   | no       |
        | invalid | some     |
