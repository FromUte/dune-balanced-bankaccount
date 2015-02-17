module Dune::Balanced::Bankaccount
  class Interface

    def name
      'balanced-bankaccount'
    end

    def payment_path(resource)
      key = "#{ActiveModel::Naming.param_key(resource)}_id"
      Dune::Balanced::Bankaccount::Engine.
        routes.url_helpers.new_payment_path(key => resource)
    end

    def account_path
      Dune::Balanced::Bankaccount::Engine.
        routes.url_helpers.new_account_path
    end

    def fee_calculator(value)
      TransactionAdditionalFeeCalculator.new(value)
    end

    def payout_class
      Dune::Balanced::Payout
    end

  end
end
