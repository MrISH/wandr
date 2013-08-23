module FlickrApi
  require 'net/http'
  require 'uri'
  require 'rexml/document'

  def search(search_conditions, page)
    uri, http, request = build_http_request(search_conditions, page)
    xml_data = make_http_request_and_return_body(uri, http, request)
    parse_xml_and_return_objects(xml_data)
  end

  def build_http_request(search_conditions, page)
    uri = URI.parse( "http://api.flickr.com/services/rest/" )
    params = {'method' => 'flickr.photos.search', 'api_key' => 'ac32760a7c068fdcbc4cd21d96b28789', 'per_page' => 50, 'sort' => 'relevance', 'media' => 'photos', 'tags' => search_conditions, 'page' => page}
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path)
    request.set_form_data( params )
    return uri, http, request
  end

  def make_http_request_and_return_body(uri, http, request)
    # instantiate a new Request object
    request = Net::HTTP::Get.new( uri.path+ '?' + request.body )
    # make the HTTP request
    response = http.request(request)
    # get the response, which will be formatted as XML
    xml_data = response.body
    return xml_data
  end

  def parse_xml_and_return_objects(xml_data)
    # initialize emtpy arry to add URLs to
    flickr_urls = []
    # load xml_data into REXML for parsing
    doc = REXML::Document.new(xml_data)

    # loop through and parse each element and turn it into a URL
    doc.root.elements[1].each_element { |e|
      url = "http://farm" + e.attributes['farm'] + ".static.flickr.com/" + e.attributes['server'] + "/" + e.attributes['id'] + "_" + e.attributes['secret'] + ".jpg";
      flickr_urls.push(url)
    }
    # get total page count
    number_of_pages = doc.root.elements[1].attributes['pages']
    # get current page number
    current_page = doc.root.elements[1].attributes['page']
    # return urls, total page number, and current page number
    return flickr_urls, number_of_pages, current_page
  end

end