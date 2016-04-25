require 'spec_helper'

describe 'categories/index' do

  it 'renders a list of categories' do
    categories = 5.times.to_a.map{ FactoryGirl.create( :category ) }
    assign(:categories, categories )
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'tr>td', text: categories.first.name
    assert_select 'tr>td', text: categories.last.name
  end
  it 'renders an empty list of categories' do
    assign(:categories, [] )
    render
  end
  it 'renders a single category' do
    c = FactoryGirl.create(:category)
    assign(:categories, [c] )
    render
    assert_select 'tr>td', text: c.name
  end
end
