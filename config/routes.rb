Rails.application.routes.draw do
  root "home#index", :as => :root

  get "/atom.xml" => "home#feed", as: :feed

  resources :advisories, only: [:new, :show, :index, :create] do
    collection do
      post "preview"
    end
  end
end
