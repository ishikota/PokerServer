Rails.application.routes.draw do
  namespace :api, format: 'json' do
    namespace :v1 do
      resources :players, only: [:create, :destroy]
      resources :rooms, only: [:index, :create, :destroy]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
end
