review_path = ->(contribution) do
  Neighborly::Balanced::Bankaccount::Engine.
    routes.url_helpers.new_payment_path(contribution_id: contribution)
end

value_with_fees = ->(value) do
  Neighborly::Balanced::Bankaccount::TransactionAdditionalFeeCalculator.new(value).gross_amount
end

account_path = -> do
  Neighborly::Balanced::Bankaccount::Engine.
    routes.url_helpers.new_account_path()
end

begin
  PaymentEngine.register(name:            'balanced-bankaccount',
                          locale:         'en',
                          value_with_fees: value_with_fees,
                          review_path:    review_path,
                          account_path:   account_path)
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
