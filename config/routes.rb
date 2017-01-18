Rails.application.routes.draw do
  root "home#index", :as => :root

  get "/new" => "home#new", :as => :new_advisory
  post "/preview" => "home#preview", :as => :preview_advisory
  post "/create" => "home#create", :as => :create_advisory
  get "/atom.xml" => "home#feed"
end
