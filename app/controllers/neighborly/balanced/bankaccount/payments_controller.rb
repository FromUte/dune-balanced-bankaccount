module Neighborly::Balanced::Bankaccount
  class PaymentsController < AccountsController
    def create
      attach_bank_to_customer
      update_customer

      payment = Neighborly::Balanced::Bankaccount::PaymentGenerator.new(
        customer,
        resource,
        resource_params
      )
      payment.complete

      redirect_to(*checkout_response_params(payment.status))
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end

    protected
    def resource
      @resource ||= if params[:payment][:match_id].present?
                      Match.find(params[:payment].fetch(:match_id))
                    else
                      Contribution.find(params[:payment].fetch(:contribution_id))
                    end
    end

    def resource_name
      resource.class.model_name.singular.to_sym
    end

    def checkout_response_params(status)
      route_params = [resource.project.permalink, resource.id]

      {
        contribution: {
          succeeded: [
            main_app.project_contribution_path(*route_params)
          ],
          pending: [
            main_app.project_contribution_path(*route_params)
          ],
          failed: [
            main_app.edit_project_contribution_path(*route_params),
            alert: t('.errors.default')
          ]
        },
        match: {
          succeeded: [
            main_app.project_match_path(*route_params)
          ],
          pending: [
            main_app.project_match_path(*route_params)
          ],
          failed: [
            main_app.edit_project_match_path(*route_params),
            alert: t('.errors.default')
          ]
        }
      }.fetch(resource_name).fetch(status)
    end
  end
end
