Rails.application.routes.draw do
  resources :icons
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :recipes do
    get 'gallery', to: 'gallery'
  end
  resources :recipes
  
  namespace :api do
    post 'updategoodcount', to: 'updategoodcount'
    post 'saverecipeimage', to: 'saverecipeimage'
    patch 'saverecipeimage', to: 'saverecipeimage'
  end

  get '/orders', to: 'orders#index'
  post '/orders', to: 'orders#update'
  
  root to: 'recipes#index'
end
