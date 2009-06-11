Feature: PiM to PREMIS Conversion
  A METS document with PREMIS embedded according to the PREMIS-in-METS best
  practice should be extracted into a PREMIS document

  Scenario: Convert PREMIS-in-METS to PREMIS for view in a browser
    Given a PREMIS-in-METS document
    When I convert it
    Then a PREMIS document should be returned

  Scenario: Convert PREMIS-in-METS with a PREMIS container to PREMIS
    Given a PREMIS-in-METS document with PREMIS embedded as a container
    When I convert it
    Then a PREMIS document should be returned

  Scenario: Convert PREMIS-in-METS with PREMIS buckets to PREMIS
    Given a PREMIS-in-METS document with PREMIS embedded as buckets
    When I convert it
    Then a PREMIS document should be returned
