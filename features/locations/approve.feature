@javascript
Feature: Locations need to be approved by staff before being displayed on the map
  Scenario: A location gets approved by staff through bulk approval
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

  Scenario: A location gets approved by staff through the edit screen
    Given I am logged in as an Admin
    And I can connect to google maps
    And the following location records
      | name         | email                       |
      | Tap & Barrel | farmer01@youngagrarians.org |
    And I am on the "locations" page
    When I select the first location
    And I click "Edit Selected"
    And I choose "Approved"
    And I click "Save Location"
    And I wait 1 seconds
    Then the location owner should get an email about the location getting approved

  Scenario: A location gets approved once then re-approved again
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

    When I clear my emails
    And I select the first location
    And I click "Edit Selected"
    And I choose "Not Approved"
    And I click "Save Location"
    And I wait 1 second
    Then the location owner should not get an email about the location getting approved

    When I select the first location
    And I click "Approve Selected"
    And I wait 1 seconds
    Then the location owner should get an email about the location getting approved