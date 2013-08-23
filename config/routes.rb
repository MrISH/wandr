Wandr::Application.routes.draw do
  root :to => 'searches#index'
  get 'searches' => 'searches#index'
  get 'results' => 'searches#results'
  post 'do_search' => 'searches#do_search'
end
