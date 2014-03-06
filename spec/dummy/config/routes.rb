Rails.application.routes.draw do
  mount Neighborly::Balanced::Bankaccount::Engine => '/', as: 'neighborly_balanced_bankaccount'

  resources :projects do
    resources :contributions
  end

  resources :users do
    member do
      get :payments
    end
  end
end
