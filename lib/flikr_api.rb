module FlikrApi

  def search(search_conditions, page)
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

end