module Neighborly::Balanced::Bankaccount
  class AccountsController < ActionController::Base
    def new
      prepare_new_view
    end

    def create
      update_customer

      redirect_to main_app.payments_user_path(current_user)
    end

    private

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
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

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end
  end
end

