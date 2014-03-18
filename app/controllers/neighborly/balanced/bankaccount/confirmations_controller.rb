module Neighborly::Balanced::Bankaccount
  class ConfirmationsController < ApplicationController
    before_action :check_bank_account_availability, only: :new

    def new
      @verification = bank_account.verifications.try(:last)
      render layout: 'application'
    end

    def create; end

    private
    def check_bank_account_availability
      if bank_account
        if bank_account.verifications.try(:last).try(:state) == 'verified'
          flash.alert = t('.errors.already_confirmed')
        end
      else
        flash.alert = t('.errors.bank_account_not_found')
      end
      redirect_to main_app.payments_user_path(current_user) if flash.alert.present?
    end

    def bank_account
      @bank_account ||= customer.bank_accounts.try(:last)
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end
