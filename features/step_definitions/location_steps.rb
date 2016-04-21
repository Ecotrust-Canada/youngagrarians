# TODO: this can probably be refactored to be part of the env.rb
Given /^I can connect to google maps$/ do
  Gmaps4rails.stub(:geocode) do |*args|
    case args[0]
    when '1 Athelets Way, Vancouver, BC'
      [{ lat: 48.856614, lng: 2.3522219, matched_address: '1 Athelets Way, Vancouver, BC', bounds: { 'northeast' => { 'lat' => 48.902145, 'lng' => 2.4699209 }, 'southwest' => { 'lat' => 48.815573, 'lng' => 2.224199 } }, full_data: { 'address_components' => [{ 'long_name' => 'Paris', 'short_name' => 'Paris', 'types' => %w(locality political) }, { 'long_name' => 'Vancouver', 'short_name' => '75', 'types' => %w(administrative_area_level_2 political) }, { 'long_name' => 'Ile-de-France', 'short_name' => 'IdF', 'types' => %w(administrative_area_level_1 political) }, { 'long_name' => 'Canada', 'short_name' => 'CA', 'types' => %w(country political) }], 'formatted_address' => '445 W 2nd Ave, Vancouver', 'geometry' => { 'bounds' => { 'northeast' => { 'lat' => 48.902145, 'lng' => 2.4699209 }, 'southwest' => { 'lat' => 48.815573, 'lng' => 2.224199 } }, 'location' => { 'lat' => 48.856614, 'lng' => 2.3522219 }, 'location_type' => 'APPROXIMATE', 'viewport' => { 'northeast' => { 'lat' => 48.9153104, 'lng' => 2.4802813 }, 'southwest' => { 'lat' => 48.7978487, 'lng' => 2.2241625 } } }, 'types' => %w(locality political) } }]
    end
  end
end

When(/^I select the first location$/) do
  within 'tbody td:first-child' do
    check ''
  end
end

Then(/^the location owner should( not)? get an email about the location getting approved$/) do |negate|
  (last_email.should be_nil; next) if negate
  last_email.to.first.should(eq('farmer01@youngagrarians.org'))
  last_email.subject.should(eq('Young Agrarians Resource Map - your listing is live!'))
end
