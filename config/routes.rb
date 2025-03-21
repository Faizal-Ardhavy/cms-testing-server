Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post "upload", to: "users#upload_file"
      put "upload", to: "users#update_file_put"
      patch "upload", to: "users#update_file_patch"
    end
  end
end
