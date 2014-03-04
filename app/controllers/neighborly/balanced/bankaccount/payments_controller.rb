module Neighborly::Balanced::Bankaccount
  class PaymentsController < ActionController::Base
    def new
      prepare_new_view
    end

    def create
      update_customer

      contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      redirect_to main_app.project_contribution_path(
        contribution.project.permalink,
        contribution.id
      )
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
