module Neighborly::Balanced::Bankaccount
  class AccountsController < ActionController::Base
    def new
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @bank_account            = customer.bank_accounts.try(:last)
    end

    def create
      attach_bank_to_customer

      flash[:success] = t('neighborly.balanced.bankaccount.accounts.create.success')
      redirect_to main_app.payments_user_path(current_user)
    end

    private

    def attach_bank_to_customer
      bank_account = resource_params.fetch(:use_bank)
      unless customer_bank_accounts.any? { |c| c.id.eql? bank_account }
        unstore_all_bank_accounts
        # The reload here is needed because of Balanced conflit error
        customer.reload.add_bank_account(bank_account)
      end
    end

    def unstore_all_bank_accounts
      customer_bank_accounts.each do |bank|
        bank.unstore
      end
    end

    def customer_bank_accounts
      @bank_accounts ||= customer.bank_accounts
    end

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :use_bank,
                    :pay_fee,
                    user: {})
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end

