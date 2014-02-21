Rails.application.routes.draw do
  mount Neighborly::Balanced::Bankaccount::Engine => '/', as: 'neighborly_balanced_bankaccount'
end
