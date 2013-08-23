class SearchesController < ApplicationController
  include FlikrApi

  def index

  end

  def do_search
    @search_conditions = params[:search_conditions]
    @flickr_urls, @number_of_pages, @current_page = search(@search_conditions, params[:page])

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
