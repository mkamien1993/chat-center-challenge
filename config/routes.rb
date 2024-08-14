Rails.application.routes.draw do
  # Set the root path to the HomeController's index action
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :products
  resources :orders do
    collection do
      get 'search'
    end
  end

  devise_for :users
end
