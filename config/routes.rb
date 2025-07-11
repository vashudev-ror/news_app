Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  root to: 'articles#index'
  resources :articles, only: [:index, :show]
  get '/filtered_authors', to: 'articles#filtered_authors'

  # Defines the root path route ("/")
  # root "posts#index"
end
