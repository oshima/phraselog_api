Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    resources :users, param: :id_string, only: [:create, :show] do
      resources :phrases, param: :id_string, only: [:index], module: :users
      resources :liked_phrases, param: :id_string, only: [:index, :create, :show, :destroy], module: :users
    end
    resources :phrases, param: :id_string
  end
end
