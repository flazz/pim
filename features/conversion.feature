Feature: Conversion
  In order to convert between premis : premis in mets
  As a user
  I want it to handle namespace prefixes properly
  
  Scenario: louis-2-0.xml
  Given I give the url to louis 2.0
  When I convert it
  Then a PREMIS document should be returned
  

  
