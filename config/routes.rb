MiaomiaoCat::Application.routes.draw do
  resources :source_websites
  resources :items
  root :to => 'items#index'
  resources :crawlings
end
