Feature: Conversion
  In order to convert between premis : premis in mets
  As a user
  I want it to handle namespace prefixes properly
  
  Scenario: louis-2-0.xml
  Given I give the url to louis 2.0
  When I convert it
  Then a PREMIS document should be returned
  
  Scenario: premis1.x
  Given I provide PREMIS which is not version 2.0
  When I convert it
  Then I should get a message saying only PREMIS 2.0 is supported
  
