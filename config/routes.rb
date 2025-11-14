Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # GET /forecast?q=<address_or_zip_or_place>
  get 'forecast', to: 'weather#show'
  # root for convenience
  root to: 'weather#show'
end
