module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^I fill in "([^""]*)" with "([^""]*)"$/ do |field, value|
  fill_in(field, :with => value, match: :prefer_exact)
end

When(/^I click on my name within "(.*?)"$/) do |selector|
  with_scope(selector) do
    click_link(my.user.name)
  end
end

When(/^I click the "(.*?)" button(?: within "([^"]*)")?$/) do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

When /^(?:|I )click "([^"]*)"(?: within "([^"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(link)
  end
end

When /^I click "(.*)" css$/ do |selector|
  find(selector).click
end

When(/^I click "(.*?)" within a new window$/) do |link|
  within_window(page.driver.browser.window_handles.last) do
    click_link(link)
  end
end

When /^(?:|I )fill in the following(?: within "([^"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      step %{I fill in "#{name}" with "#{value}"}
    end
  end
end

Given(/^I select "(.*?)" as "(.*?)"$/) do |from, value|
  select value, :from => from
end

Given(/^I choose "(.*?)" as "(.*?)"$/) do |from, value|
  within from do
    choose value
  end
end

Given(/^I check "(.*?)" as "(.*?)"$/) do |from, value|
  within from do
    check value
  end
end

Given(/^I uncheck "(.*?)""$/) do |value|
  uncheck value
end

Then(/^I should see an error "(.*?)"$/) do |message|
  page.should have_css('.flash-error', text: message)
end

Then(/^I should see a notice "(.*?)"$/) do |message|
  page.should have_css('.flash-notice', text: message)
end

Then /^I should see "([^""]*)"$/ do |text|
  page.should have_content(text)
end

Then /^I should not see "([^\"]*)"$/ do |text|
  page.should have_no_content(text)
end

Then /^I should be on the "(.+)" page$/ do |page_name|
  current_path = URI.parse(current_url).request_uri
  current_path.should == send("#{page_name.sub(' ', '_')}_path")
end

Given(/^I am on the "(.*)" page$/) do |page_name|
  visit send("#{page_name.sub(' ', '_')}_path")
end

Then /^I should see "([^\"]*)" within "(.*)"$/ do |text, context|
  within(context) do
    page.should have_content(text)
  end
end

When /^I reload the page$/ do
  current_path = URI.parse(current_url).request_uri
  visit current_path
end

# PLEASE USE THIS WITH CAUTION! It adds a lot of time to the tests
# making them more expensive to run! Only use if you absolutely CANNOT
# find an alternative.
When /^I wait (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end

When /^show me the page$/ do
  save_and_open_page
end

Then /^pry now/ do
  binding.pry
end