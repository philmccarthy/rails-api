Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/merchants/find_all', to: 'merchants/search#index'
      get '/merchants/most_items', to: 'merchants/items_sold#index'
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index]
      end
      
      get 'items/find', to: 'items/search#index'
      resources :items do
        get '/merchant', to: 'merchants#show'
      end

      get '/revenue/merchants', to: 'revenue/merchants#index'
      get '/revenue/merchants/:id', to: 'revenue/merchants#show'
      get '/revenue/items', to: 'revenue/items#index'
      get '/revenue/unshipped', to: 'revenue/unshipped_invoices#index'
    end
  end
end
