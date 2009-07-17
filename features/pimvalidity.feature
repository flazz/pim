Feature: PREMIS in METS conformance
  Elements not conforming to the best practice should be reported.
  Each violation should cite the section in question of the best practice.

  Scenario Outline: PiM validation
    Given I submit a(n) <state> PiM document
    When I press validate
    Then a result document should be returned
    And it should contain <quantity> pim best practices violations

    Examples:
        | state          | quantity |
        | conforming     | no       |
        | non-conforming | some     |
