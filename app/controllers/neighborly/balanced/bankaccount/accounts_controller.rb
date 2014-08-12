module Neighborly::Balanced::Bankaccount
  class AccountsController < ActionController::Base
    before_filter :authenticate_user!

    def new
      @bank_account = customer.bank_accounts.to_a.last
      render layout: false
    end

    def create
      attach_bank_to_customer

      flash[:success] = t('neighborly.balanced.bankaccount.accounts.create.success')
      redirect_to main_app.payments_user_path(current_user)
    end

    private

    def attach_bank_to_customer
      bank_account = Balanced::BankAccount.fetch(resource_params.fetch(:use_bank))
      unless customer_bank_accounts.any? { |c| c.href.eql? bank_account.href }
        Neighborly::Balanced::Contributor.
          find_or_create_by(user_id: current_user.id).
          update_attributes(bank_account_uri: bank_account.href)
        notify_user_about_replacement
        unstore_all_bank_accounts
        # Not calling #reload raises Balanced::ConflictError when attaching a
        # new card after unstoring others.
        bank_account.associate_to_customer(customer)
        verify_bank_account(bank_account)
      end
    end

    def notify_user_about_replacement
      Notification.notify('balanced/bankaccount/bank_account_replaced',
                          current_user) if customer_bank_accounts.any?
    end

    def verify_bank_account(bank_account)
      bank_account.verify
    end

    def unstore_all_bank_accounts
      customer_bank_accounts.each do |bank|
        bank.unstore
      end
    end

    def customer_bank_accounts
      @bank_accounts ||= customer.bank_accounts.to_a
    end

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :match_id,
                    :use_bank,
                    :pay_fee,
                    user: {})
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end
  end
end

