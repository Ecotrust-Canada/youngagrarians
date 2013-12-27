Given(/^I am logged in as an Admin$/) do
  steps %Q{
    Given the following user records
      | email                    | password |
      | admin@youngagrarians.org | secret12 |
    And I am logged in as "admin@youngagrarians.org" with password "secret12"
  }
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |username, password|
  visit login_path
  fill_in "email", with: username
  fill_in "password", with: password
  click_button "Sign In"
end

