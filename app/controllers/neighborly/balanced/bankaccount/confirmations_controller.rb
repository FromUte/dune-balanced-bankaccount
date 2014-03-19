module Neighborly::Balanced::Bankaccount
  class ConfirmationsController < ApplicationController
    before_filter :authenticate_user!
    before_action :check_bank_account_availability, only: :new

    def new
      @verification  = verification
      @contributions = current_user.contributions.with_state(:payment_authorized)
      render layout: 'application'
    end

    def create
      verification.confirm(params[:confirmation][:amount_1],
                           params[:confirmation][:amount_2])

      flash.notice = t('.messages.success')
      redirect_to main_app.payments_user_path(current_user)
    rescue Balanced::BankAccountVerificationFailure
      flash.alert = t('.messages.unnable_to_verify')
      check_for_remaining_attempts
      redirect_to new_confirmation_path
    end

    private
    def check_for_remaining_attempts
      if verification.remaining_attempts == 0
        flash.alert = t('.messages.not_remaining_attempts')
        bank_account.verify
      end
    end

    def check_bank_account_availability
      if bank_account
        if verification.try(:state) == 'verified'
          flash.alert = t('.errors.already_confirmed')
          error = true
        end
      else
        flash.alert = t('.errors.bank_account_not_found')
        error = true
      end
      redirect_to main_app.payments_user_path(current_user) if error == true
    end

    def verification
      @verification ||= bank_account.verifications.try(:first)
    end

    def bank_account
      @bank_account ||= customer.bank_accounts.try(:first)
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end
