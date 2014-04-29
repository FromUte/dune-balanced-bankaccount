module Neighborly::Balanced::Bankaccount
  class PaymentsController < AccountsController
    def create
      attach_bank_to_customer
      update_customer

      @payment = Neighborly::Balanced::Bankaccount::PaymentGenerator.new(
        customer,
        resource,
        resource_params
      )
      @payment.complete

      redirect_to(*checkout_response_params)
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end

    protected
    def resource
      @resource ||= Contribution.find(params[:payment].fetch(:contribution_id))
    end

    def resource_name
      resource.class.model_name.singular.to_sym
    end

    def checkout_response_params
      {
        contribution: {
          succeeded: [
            main_app.project_contribution_path(
              resource.project.permalink,
              resource.id
            )
          ],
          failed: [
            main_app.edit_project_contribution_path(
              resource.project.permalink,
              resource.id
            ),
            alert: t('.errors.default')
          ]
        }
      }.fetch(resource_name).fetch(@payment.status)
    end
  end
end
