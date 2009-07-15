Feature: PREMIS to PiM Conversion
  A PREMIS document should be converted to a METS document containing PREMIS XML

  Scenario: Convert PREMIS with structural representations to METS
    Given a PREMIS document
    When I convert it
    Then a choice of potential representations will be returned

  Scenario: Convert PREMIS to METS with a PREMIS container
    Given a PREMIS document
    And I want a premis container
    When I convert it
    Then a METS document should be returned
    And it should be valid
    And it should conform to PiM BP
    And it should have a single PREMIS container within a METS digiprovMD section
    
  Scenario Outline: Convert PREMIS to METS with METS buckets
    Given a PREMIS document
    And I want PREMIS elements sorted into specific METS buckets
    When I convert it
    Then a METS document should be returned
    And it should be valid
    And it should conform to PiM BP
    And it should have PREMIS <PREMIS element> in METS <METS bucket> section

  Examples: appropriate buckets
            | PREMIS element | METS bucket |
            | object         | techMD      |
            | events         | digiprovMD  |
            | agents         | digiprovMD  |
            | rights         | rightsMD    |
