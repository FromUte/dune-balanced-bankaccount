module Neighborly::Balanced::Bankaccount
  class AccountsController < ActionController::Base
    def new
      prepare_new_view
    end

    def create
      attach_bank_to_customer

      flash[:success] = t('neighborly.balanced.bankaccount.accounts.create.success')
      redirect_to main_app.payments_user_path(current_user)
    end

    private

    def attach_bank_to_customer
      bank_account = resource_params.fetch(:use_bank)
      unless customer.bank_accounts.any? { |c| c.id.eql? bank_account }
        customer.add_bank_account(resource_params.fetch(:use_bank))
      end
    end

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :use_bank,
                    :pay_fee,
                    user: {})
    end

    def prepare_new_view
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @bank_account            = customer.bank_accounts.try(:last)
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end

