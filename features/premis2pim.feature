Feature: PREMIS to PiM Conversion
  A PREMIS document should be converted to a METS document containing PREMIS XML

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
            
  Scenario Outline: Convert PREMIS to METS buckets with ADMID linking
    Given a PREMIS document with <first element> linking to <second element>
    And I want PREMIS elements sorted into specific METS buckets
    When I convert it
    Then a METS document should be returned
    And it should be valid
    And it should conform to PiM BP
    And it should have <first element> METS bucket with an ADMID reference to <second element> METS bucket
    
  Examples: linking IDs/ADMIDs
    | first element | second element                          |
    | an object     | an event                                | 
    | an object     | an object (and event) in a relationship |
    | an event      | an object                               |
    | an event      | an agent                                |
    | rights        | an agent                                |
    | rights        | an object                               |

  Scenario: Convert PREMIS to PiM when a PREMIS ID conflicts
    Given a PREMIS document with a PREMIS object with xmlID 'object-1'
    And I want PREMIS elements sorted into specific METS buckets
    When I convert it
    Then a METS document should be returned
    And all the PREMIS xmlIDs and IDRefs should be prefixed with 'premis_'