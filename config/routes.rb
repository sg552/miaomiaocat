MiaomiaoCat::Application.routes.draw do
  resources :source_websites do
    member do
      post :fetch
    end
  end
  resources :crawlers
  resources :items
  root :to => 'items#index'end
