Feature: Locations need to be approved by staff before being displayed on the map
  @javascript
  Scenario: A location gets approved by staff
    Given I am logged in as an Admin
    And I can connect to google maps
    And the following location records
      | name         | email                       |
      | Tap & Barrel | farmer01@youngagrarians.org |
    And I am on the "locations" page
    When I select the first location
    And I click "Approve Selected"
    And I wait 1 seconds
    Then the location owner should get an email about the location getting approved