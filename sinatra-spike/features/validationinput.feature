Feature: Validation Input
  Support a URL, file upload and direct input of XML

  Scenario: Validate via URL
    Given I enter a url to a PiM document
    And I press validate
    Then a result document should be returned

  Scenario: Validate a file upload
    Given I select to upload a PiM document file
    And I press validate
    Then a result document should be returned

  Scenario: Validate direct input of XML
    Given I enter PiM XML in the text area
    And I press validate
    Then a result document should be returned
