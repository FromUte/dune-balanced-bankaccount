module Neighborly::Balanced::Bankaccount
  class PaymentsController < AccountsController
    def create
      attach_bank_to_customer
      update_customer

      contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      redirect_to main_app.project_contribution_path(
        contribution.project.permalink,
        contribution.id
      )
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end
  end
end
