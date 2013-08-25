require 'spec_helper'
include FlickrApi

describe FlickrApi do

  before :each do
    @search_conditions = "cats"
    @page = '5'

    @body = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<rsp stat=\"ok\">\n<photos page=\"5\" pages=\"39786\" perpage=\"50\" total=\"1989290\">\n\t<photo id=\"2725780198\" owner=\"91621746@N00\" secret=\"5ac7130de7\" server=\"3116\" farm=\"4\" title=\"IMG_5628\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9085742138\" owner=\"93261850@N07\" secret=\"23ecc989f7\" server=\"7402\" farm=\"8\" title=\"Dino wat is dat nu op de foto!\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9547000607\" owner=\"100563100@N08\" secret=\"2122881e21\" server=\"2817\" farm=\"3\" title=\"DSC05929\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9494606708\" owner=\"9641560@N06\" secret=\"3962423021\" server=\"2830\" farm=\"3\" title=\"Willie\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" />\n\t<photo id=\"9475882990\" owner=\"9641560@N06\" secret=\"0af0bc745c\" server=\"2814\" farm=\"3\" title=\"Little One\" ispublic=\"1\" isfriend=\"0\" isfamily=\"0\" /></photos>\n</rsp>\n"

    @resulting_image_urls = ["http://farm4.static.flickr.com/3116/2725780198_5ac7130de7.jpg", "http://farm8.static.flickr.com/7402/9085742138_23ecc989f7.jpg", "http://farm3.static.flickr.com/2817/9547000607_2122881e21.jpg", "http://farm3.static.flickr.com/2830/9494606708_3962423021.jpg", "http://farm3.static.flickr.com/2814/9475882990_0af0bc745c.jpg"]

    @number_of_pages_of_cats = "39786"
    @current_page_of_cats = "5"

    stub_http_request(:post, "http://api.flickr.com/services/rest/").
    with(:body => {params: {"api_key" => "ac32760a7c068fdcbc4cd21d96b28789", "per_page" => "50", "sort" => "relevance", "media" => "photos", "tags" => @search_conditions, "page" => @page}},
                  :headers => {'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'Content-Length' => '145', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
    to_return(:status => [200], body: @body, :headers => {})
  end

  describe "search" do
    describe "build_http_request" do
      it "should build and return the uri, http, and request objects" do
        @uri, @http, @request = FlickrApi.build_http_request(@search_conditions, @page)
        @uri.to_s.should eq("http://api.flickr.com/services/rest/")
        @http.inspect.should eq("#<Net::HTTP api.flickr.com:80 open=false>")
        @request.inspect.should eq("#<Net::HTTP::Get GET>")
      end
    end

    describe "make_http_request_and_return_body" do
      it "should make the http request and return the reponse body" do
        uri = URI.parse( "http://api.flickr.com/services/rest/" )
        params = {api_key: 'ac32760a7c068fdcbc4cd21d96b28789', per_page: 50, sort: 'relevance', media: 'photos', tags: @search_conditions, page: @page}
        xml_data = RestClient.post(uri.to_s, params: params)
        xml_data.should eq(@body)
      end
    end

    describe "parse_xml_and_return_objects" do
      it "should parse the repsonse body XML and return an array of image URLs, total number of pages, and current page number" do
        image_urls, number_of_pages, current_page = FlickrApi.parse_xml_and_return_objects(@body)
        image_urls.should eq(@resulting_image_urls)
        number_of_pages.should eq(@number_of_pages_of_cats)
        current_page.should eq(@current_page_of_cats)
      end
    end
  end

end
