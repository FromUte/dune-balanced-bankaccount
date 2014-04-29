module Neighborly::Balanced::Bankaccount
  class Payment < PaymentBase
    def checkout!
      @debit = @customer.debit(amount:     amount_in_cents,
                               source_uri: debit_resource_uri,
                               appears_on_statement_as: ::Configuration[:balanced_appears_on_statement_as],
                               description: debit_description,
                               on_behalf_of_uri: project_owner_customer.uri,
                               meta: meta)
      resource.confirm!
    rescue Balanced::BadRequest
      @status = :failed
      resource.cancel!
    ensure
      resource.update_attributes(
        payment_id:                       @debit.try(:id),
        payment_method:                   engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: attrs[:pay_fee]
      )
    end

    def successful?
      %i(pending succeeded).include? status
    end

    def debit_resource_uri
      attrs.fetch(:use_bank) { contributor.bank_account_uri }
    end

    def contributor
      @contributor ||= Neighborly::Balanced::Contributor.find_by(uri: @customer.uri)
    end

    private
    def resource_name
      resource.class.model_name.singular
    end

    def debit_description

      I18n.t('description',
             project_name: resource.try(:project).try(:name),
             scope: "neighborly.balanced.bankaccount.payments.debit.#{resource_name}")
    end

    def project_owner_customer
      @project_owner_customer ||= Neighborly::Balanced::Customer.new(
        resource.project.user, {}).fetch
    end

    def meta
      meta = {
              payment_service_fee: fee_calculator.fees,
              payment_service_fee_paid_by_user: attrs[:pay_fee],
              project: {
                id:        resource.project.id,
                name:      resource.project.name,
                permalink: resource.project.permalink,
                user:      resource.project.user.id
              },
              user: {
                id:        resource.user.id,
                name:      resource.user.display_name,
                email:     resource.user.email,
                address:   { line1:        resource.user.address_street,
                             city:         resource.user.address_city,
                             state:        resource.user.address_state,
                             postal_code:  resource.user.address_zip_code
                }
              }
            }
      if resource.respond_to? :reward
        meta.merge!({
          reward: {
                id:          resource.reward.try(:id),
                title:       resource.reward.try(:title),
                description: resource.reward.try(:description)
              }
          })
      end

      meta
    end
  end
end
