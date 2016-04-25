require 'spec_helper'

describe 'categories/new' do
  before(:each) do
    @category = assign(:category, FactoryGirl.build( :category))
  end

  it 'renders new category form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: categories_path, method: 'post' do
      assert_select 'input#category_name', name: 'category[name]', value: @category.name
    end
  end
end
