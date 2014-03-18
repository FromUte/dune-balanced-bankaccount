module Neighborly::Balanced::Bankaccount
  class AccountsController < ActionController::Base
    before_filter :authenticate_user!

    def new
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @bank_account            = customer.bank_accounts.try(:last)
      render layout: false
    end

    def create
      attach_bank_to_customer

      flash[:success] = t('neighborly.balanced.bankaccount.accounts.create.success')
      redirect_to main_app.payments_user_path(current_user)
    end

    private

    def attach_bank_to_customer
      new_bank_account_uid = resource_params.fetch(:use_bank)
      unless customer_bank_accounts.any? { |c| c.uid.eql? new_bank_account_uid }
        unstore_all_bank_accounts
        # Not calling #reload raises Balanced::ConflictError when attaching a
        # new card after unstoring others.
        customer.reload.add_bank_account(new_bank_account_uid)
        verify_bank_account(new_bank_account_uid)
      end
    end

    def verify_bank_account(bank_account)
      Balanced::BankAccount.find(bank_account).verify
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

