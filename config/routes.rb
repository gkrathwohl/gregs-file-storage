Rails.application.routes.draw do
  resources :uploads

  root 'uploads#index'

  get '/login' => 'uploads#login'
  post '/login' => 'uploads#index'
  
  get 'uploads/:id/download' => 'uploads#download'

end
