require 'spec_helper'
include FlickrApi

describe 'index' do
  before :each, js: true do
    WebMock.allow_net_connect!
    visit root_path
  end

  it "has search field and button", js: true do
    expect(page).to have_css('input[type="text"]')
    find('#search_field').should have_button('search')
  end

  it "does not display wait message", js: true do
    find("#loading_message").should_not be_visible
  end
end

describe "do search" do

  before :each, js: true do
    WebMock.allow_net_connect!
    visit root_path
    fill_in "search_conditions", with: "cats"
    click_button "search"
  end

  it "displays loading message", js: true do
    find("#loading_message").should be_visible
  end

  it "returns Flikr results for search parameters", js: true do
    page.should have_content "Page: 1 of "
    page.should have_content "1 2 3 4 5 6 7 8 9 10 11"
    page.should have_content "next"
  end

  it "loads page X when pagination link is clicked", js: true do
    click_link "5"
    page.should have_content "Page: 5 of "
    page.should have_content "last 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
    page.should have_content "next"
  end

end