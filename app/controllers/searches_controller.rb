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
    @search_conditions = params[:search_conditions]
    @flickr_urls, @number_of_pages, @current_page = flickrAPI(@search_conditions, params[:page])

    @current_page = @current_page.to_i
    @number_of_pages = @number_of_pages.to_i


    first_three = (1..([3, @number_of_pages].min))
    middle_chunk = ([@current_page - 10, 1].max)..([@current_page + 10, @number_of_pages].min)
    last_three = (([@number_of_pages - 2, 1].max)..@number_of_pages)

    @pages_to_link_to = (first_three.to_a + middle_chunk.to_a + last_three.to_a).uniq

    respond_to do |format|
      format.js {}
    end
  end

end
