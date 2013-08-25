require 'spec_helper'
include FlickrApi
WebMock.disable_net_connect!(:allow_localhost => true)

describe 'index' do
  before :each, js: true do
    visit root_path
  end

  it "has search field and button", js: true do
    expect(page).to have_css('input[type="text"]')
    find('#search_field').should have_button('search')
  end

  it "does not display wait message", js: true do
    page.should_not have_selector("#loading_message")
  end
end

describe "do search" do

  context "with search conditions present" do
    before :each, js: true do
      @search_conditions = "cats"
      @page = '5'
      @total_pages = "39786"
      @body_page_1 = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<rsp stat=\"ok\">\n<photos page=\"1\" pages=\"#{@total_pages}\" perpage=\"50\" total=\"1989290\">\n\t<photo id=\"2725780198\" owner=\"91621746@N00\" secret=\"5ac7130de7\" server=\"3116\" farm=\"4\" title=\"IMG_5628\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9085742138\" owner=\"93261850@N07\" secret=\"23ecc989f7\" server=\"7402\" farm=\"8\" title=\"Dino wat is dat nu op de foto!\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9547000607\" owner=\"100563100@N08\" secret=\"2122881e21\" server=\"2817\" farm=\"3\" title=\"DSC05929\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9494606708\" owner=\"9641560@N06\" secret=\"3962423021\" server=\"2830\" farm=\"3\" title=\"Willie\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9475882990\" owner=\"9641560@N06\" secret=\"0af0bc745c\" server=\"2814\" farm=\"3\" title=\"Little One\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" /></photos>\n</rsp>\n"

      @body_page_5 = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<rsp stat=\"ok\">\n<photos page=\"5\" pages=\"39786\" perpage=\"50\" total=\"1989290\">\n\t<photo id=\"2725780198\" owner=\"91621746@N00\" secret=\"5ac7130de7\" server=\"3116\" farm=\"4\" title=\"IMG_5628\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9085742138\" owner=\"93261850@N07\" secret=\"23ecc989f7\" server=\"7402\" farm=\"8\" title=\"Dino wat is dat nu op de foto!\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9547000607\" owner=\"100563100@N08\" secret=\"2122881e21\" server=\"2817\" farm=\"3\" title=\"DSC05929\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9494606708\" owner=\"9641560@N06\" secret=\"3962423021\" server=\"2830\" farm=\"3\" title=\"Willie\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9475882990\" owner=\"9641560@N06\" secret=\"0af0bc745c\" server=\"2814\" farm=\"3\" title=\"Little One\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" /></photos>\n</rsp>\n"

      @number_of_pages_of_cats = "39786"
      @current_page_of_cats = "5"

      # stub request for first page of results
      stub_request(:get, "http://api.flickr.com/services/rest/?api_key=ac32760a7c068fdcbc4cd21d96b28789&media=photos&method=flickr.photos.search&page&per_page=50&sort=relevance&tags=#{@search_conditions}").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => @body_page_1, :headers => {})

      # stub request for 5th page of results
      stub_request(:get, "http://api.flickr.com/services/rest/?api_key=ac32760a7c068fdcbc4cd21d96b28789&media=photos&method=flickr.photos.search&page=#{@page}&per_page=50&sort=relevance&tags=#{@search_conditions}").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => @body_page_5, :headers => {})


      visit root_path
      fill_in "search_conditions", with: @search_conditions
      click_button "search"
    end

    it "displays loading message while loading results", js: true do
      find("#loading_message").should be_visible
    end

    it "renders Flikr results for search parameters", js: true do
      page.should have_content "Page: 1 of #{@total_pages}"
      page.should have_content "1 2 3 4 5 6 7 8 9 10 11"
      page.should have_content "next"
    end

    it "renders page 5 when pagination link #5 is clicked", js: true do
      click_link "5"
      page.should have_content "Page: 5 of #{@total_pages}"
      page.should have_content "last 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
      page.should have_content "next"
    end

    it "renders the correct number of image results", js: true do
      expect(page).to have_selector('a.result', count: 5)
    end

    it "hides wait message after results are rendered", js: true do
      page.should have_content "Page: 1 of #{@total_pages}"
      # wait for results to render, and wait message to become hidden again
      sleep 1
      page.should_not have_selector("#loading_message")
    end
  end

  context "with no search conditions present" do
    it "renders no results", js: true do
      stub_request(:get, "http://api.flickr.com/services/rest/?api_key=ac32760a7c068fdcbc4cd21d96b28789&media=photos&method=flickr.photos.search&page&per_page=50&sort=relevance&tags=").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})
      visit root_path

      click_button "search"
      page.should_not have_content "Page: 1 of #{@total_pages}"
    end

  end

end