require 'spec_helper'

describe 'categories/show' do
  before(:each) do
    @category = assign(:category, FactoryGirl.create(:category))
  end

  it 'renders attributes in <p>' do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/#{@category.name}/)
  end
end
