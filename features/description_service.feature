Feature: Description Service
  There should be a way to create PREMIS metadata for a file.
  
  Scenario: description service
    Given I want to describe a file
    And I provide an object identifier and an ieid
    When I press describe
    Then a PREMIS document should be returned
    And it should have an object with an object identifier that matches my input
    And all linking objects should have matching identifiers
    And it should have an IEID that matches my input
    
  Scenario Outline: missing description service input
    Given I want to describe a file
    And I don't provide the <identifier>
    When I press describe
    Then I should get an error
    
    Examples:
      | identifier              |
      | object identifier type  |
      | object identifier value | 
    