module Neighborly::Balanced::Bankaccount
  class ConfirmationsController < ApplicationController
    before_filter :authenticate_user!
    before_action :check_bank_account_availability, only: :new

    def new
      @verification  = verification
      @contributions = current_user.contributions.with_state(:waiting_confirmation)
      render layout: 'application'
    end

    def create
      verification.confirm(params[:confirmation][:amount_1],
                           params[:confirmation][:amount_2])

      flash.notice = t('.messages.success')
      redirect_to main_app.payments_user_path(current_user)
    rescue Balanced::BankAccountVerificationFailure
      # Balanced does not decrease Verification#attempts_remaining
      # after a failure
      @attempts_remaining = verification.attempts_remaining - 1
      flash.alert = t('.messages.unable_to_verify')
      check_for_attempts_remaining
      redirect_to new_confirmation_path
    end

    private
    def check_for_attempts_remaining
      if @attempts_remaining.zero?
        flash.alert = t('.messages.none_attempts_remaining')
        create_new_verification
      end
    end

    def create_new_verification
      bank_account.verify
      Notification.notify('balanced/bankaccount/new_verification_started',
                          current_user)
    end

    def check_bank_account_availability
      if bank_account
        if verification.try(:verification_status) == 'succeeded'
          flash.alert = t('.errors.already_confirmed')
          has_errors = true
        end
      else
        flash.alert = t('.errors.bank_account_not_found')
        has_errors = true
      end
      redirect_to main_app.payments_user_path(current_user) if has_errors
    end

    def verification
      @verification ||= bank_account.bank_account_verifications.to_a.first
    end

    def bank_account
      @bank_account ||= customer.bank_accounts.to_a.last
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end
