class SearchesController < ApplicationController

  def flickrAPI(search_conditions, page)
    require 'net/http'
    require 'uri'
    require 'rexml/document'
    flickr_urls = []
    uri = URI.parse( "http://api.flickr.com/services/rest/" )
    params = {'method' => 'flickr.photos.search', 'api_key' => 'ac32760a7c068fdcbc4cd21d96b28789', 'per_page' => 50, 'sort' => 'relevance', 'media' => 'photos', 'tags' => search_conditions, 'page' => page}

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path)
    request.set_form_data( params )

    # instantiate a new Request object
    request = Net::HTTP::Get.new( uri.path+ '?' + request.body )

    response = http.request(request)
    xml_data = response.body
    doc = REXML::Document.new(xml_data)

    doc.root.elements[1].each_element { |e|
      url = "http://farm" + e.attributes['farm'] + ".static.flickr.com/" + e.attributes['server'] + "/" + e.attributes['id'] + "_" + e.attributes['secret'] + ".jpg";
      flickr_urls.push(url)
    }
    number_of_pages = doc.root.elements[1].attributes['pages']
    current_page = doc.root.elements[1].attributes['page']
    return flickr_urls, number_of_pages, current_page
  end



  def index

  end

  def do_search
    @flickr_urls, @number_of_pages, @current_page = flickrAPI(params[:search_conditions], params[:page])

    @current_page = @current_page.to_i
    @number_of_pages = @number_of_pages.to_i

    first = @current_page < 10 ? (1..@current_page).to_a : (1..3).to_a
    middle_1 = (@current_page < 10 ? [] : ((@current_page - 10)..@current_page).to_a)
    middle_2 = (@current_page > (@number_of_pages - 10) ? [] : (@current_page..(@current_page + 10))).to_a
    last = ((@number_of_pages - 3)..@number_of_pages).to_a

    @pages_to_link_to = (first + middle_1 + middle_2 + last).uniq

    respond_to do |format|
      format.js {}
    end
  end

end
