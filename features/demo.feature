Feature: Validation Input
  Support a URL, file upload and direct input of XML

  Scenario: Demo a round trip
    Given I navigate to the description form page
    And I select to upload the demo pdf
    When I run the demo
    Then I should end up with a conforming METS doc
