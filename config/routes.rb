Rails.application.routes.draw do
  root 'chat_rooms#index'
  
  resources :chat_rooms do
    member do
      post '/join' => 'chat_rooms#user_admit_room', as: 'join'
    end
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
end
