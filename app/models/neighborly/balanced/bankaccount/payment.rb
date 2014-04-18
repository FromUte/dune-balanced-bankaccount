module Neighborly::Balanced::Bankaccount
  class Payment < PaymentBase
    def checkout!
      @debit = @customer.debit(amount:     contribution_amount_in_cents,
                               source_uri: debit_resource_uri,
                               appears_on_statement_as: ::Configuration[:balanced_appears_on_statement_as],
                               description: debit_description,
                               on_behalf_of_uri: project_owner_customer.uri)
      @contribution.confirm!
    rescue Balanced::BadRequest
      @status = :failed
      @contribution.cancel!
    ensure
      @contribution.update_attributes(
        payment_id:                       @debit.try(:id),
        payment_method:                   @engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: @attrs[:pay_fee]
      )
    end

    def successful?
      %i(pending succeeded).include? status
    end

    def debit_resource_uri
      @attrs.fetch(:use_bank) { contributor.bank_account_uri }
    end

    def contributor
      @contributor ||= Neighborly::Balanced::Contributor.find_by(uri: @customer.uri)
    end

    private
    def debit_description
      I18n.t('neighborly.balanced.bankaccount.payments.debit.description',
             project_name: @contribution.try(:project).try(:name))
    end

    def project_owner_customer
      @project_owner_customer ||= Neighborly::Balanced::Customer.new(
        @contribution.project.user, {}).fetch
    end
  end
end
