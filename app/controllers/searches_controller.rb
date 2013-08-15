class SearchesController < ApplicationController

  def flickrAPI(search_conditions)
    require 'net/http'
    require 'uri'
    require 'rexml/document'
    @flickr_urls = []
    uri = URI.parse( "http://api.flickr.com/services/rest/" )
    params = {'method' => 'flickr.photos.search', 'api_key' => 'ac32760a7c068fdcbc4cd21d96b28789', 'per_page' => 20, 'sort' => 'relevance', 'media' => 'photos', 'tags' => search_conditions}

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path)
    request.set_form_data( params )

    # instantiate a new Request object
    request = Net::HTTP::Get.new( uri.path+ '?' + request.body )

    response = http.request(request)
    xml_data = response.body
    doc = REXML::Document.new(xml_data)

    doc.root.elements[1].each_element { |e|
      # if e.attributes['title'] =~ /#{Regexp.escape(search_conditions)}/i
        url = "http://farm" + e.attributes['farm'] + ".static.flickr.com/" + e.attributes['server'] + "/" + e.attributes['id'] + "_" + e.attributes['secret'] + ".jpg";
        @flickr_urls.push(url)
        @pages = e.attributes['pages']
        @page = e.attributes['page']
      # end
    }
    return @flickr_urls, @pages, @page
  end



  def index

  end

  def do_search
    @flickr_urls, @pages, @page = flickrAPI(params[:search_conditions])

    respond_to do |format|
      format.js {}
    end
  end

  def update_list_items
    @flickr_urls
    respond_to do |format|
      format.js { render :results }
    end
  end
end
