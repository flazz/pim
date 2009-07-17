Feature: Validation Entries Disabled
  In order to see the applicable steps in validation
  As a user
  I want to see the un-reached steps grayed-out
  
  Scenario: Gray-out past well formed
    Given a document is not well formed
    When I press validate
    Then all headings except well formedness are visually disabled
  
  Scenario: Gray-out past validation
    Given a document is not valid
    When I press validate
    Then only best practice heading is visually disabled
  
  Scenario: No gray-out
    Given a valid xml document
    When I press validate
    Then nothing is visually disabled
  
  
  