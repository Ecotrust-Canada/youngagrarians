Feature: Locations need to be approved by staff before being displayed on the map
  @javascript
  Scenario: A location gets approved by staff
    Given I am logged in as an Admin
    And I can connect to google maps
    And the following location records
      | name         |
      | Tap & Barrel |
    And I am on the "locations" page
    Then pry now
    When I select the first location
    And I press the "Approve Selected" button
    Then the location owner should get an email about the location getting approved