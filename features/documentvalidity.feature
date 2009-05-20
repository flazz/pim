Feature: Document Validity
  All validation errors and warnings should be reported

  Scenario Outline: document validation
    Given I submit a <state> document
    When I press validate
    Then a result document should be returned
    And it should contain <quantity> validation errors

    Examples:
        | state   | quantity |
        | valid   | no       |
        | invalid | some     |
