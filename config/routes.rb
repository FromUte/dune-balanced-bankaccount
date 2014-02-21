Neighborly::Balanced::Bankaccount::Engine.routes.draw do
  resources :payments, only: %i(new create)
end
