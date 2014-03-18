module Neighborly::Balanced::Bankaccount
  class ConfirmationsController < ApplicationController
    def new
      @bank_account = customer.bank_accounts.try(:last)
      render layout: 'application'
    end

    def create

    end

    private
    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end
