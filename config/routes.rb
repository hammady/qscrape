QScrape::Application.routes.draw do

  resources :brands
  resources :recipients
  resources :vehicles do
    post 'comment', on: :member
    get 'favor', on: :member
  end

  root :to => "vehicles#index"

end
