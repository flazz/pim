Feature: Validation Specifics
  When given a well-formed, schema-compliant PREMIS-in-METS document, certain 
  features should generate errors and warnings according to the best practice
  
  Scenario Outline: Misplaced PREMIS elements
    Given a document with <element> not in a <good bucket> section
    When I press validate
    Then I should get some Best Practice errors
    And they should include errors about <error type>
  
      Examples:
        | element             | good bucket            | error type                   |
        | representations     | digiprovMD or techMD   | representation placement     |
        | bitstream and files | techMD                 | bitstream and file placement |
        | the PREMIS root     | digiprovMD             | a misplaced PREMIS container |
        | rights              | rightsMD               | rights placement             |
        | events              | digiprovMD             | event placement              |
        | agent               | rightsMD or digiprovMD | agent placement              |
    
  
  Scenario: Missing PREMIS
    Given a document with no container and no buckets
    When I press validate
    Then I should get some Best Practice errors
    And they should include an error about missing PREMIS
  
  Scenario: PREMIS container and a PREMIS bucket
    Given a document with a PREMIS container and PREMIS buckets
    When I press validate
    Then I should get some Best Practice errors
    And they should include an error about choosing either buckets or the container
  
  Scenario: PREMIS agent with siblings in the wrapped XML
    Given a document with more than one agent wrapped in a rightsMD section
    When I press validate
    Then I should get some Best Practice errors
    And they should include an error about keeping agents in separate buckets
  
  Scenario: PREMIS IDRef referencing a METS bucket
    Given a document with PREMIS IDRefs referencing METS buckets
    When I press validate
    Then I should get some Best Practice errors
    And they should include errors about overlapping references
 
  Scenario: Embedded PREMIS should be referenced in an ADMID
    Given a valid document with unreferenced PREMIS buckets
    When I press validate
    Then I should get some Best Practice warnings

  