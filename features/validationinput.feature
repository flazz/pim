Feature: Validation Input
  Support a URL, file upload and direct input of XML

  Scenario: Validate via URL
    Given I navigate to the validation form page
    And I enter a url to a PiM document
    When I validate the url
    Then a result document should be returned

  Scenario: Validate a file upload
    Given I navigate to the validation form page
    And I select to upload a PiM document file
    When I validate the file
    Then a result document should be returned

  Scenario: Validate direct input of XML
  Given I navigate to the validation form page
    And I enter PiM XML in the text area
    When I validate direct input
    Then a result document should be returned
