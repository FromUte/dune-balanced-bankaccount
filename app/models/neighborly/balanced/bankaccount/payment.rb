module Neighborly::Balanced::Bankaccount
  class Payment < PaymentBase
    def checkout!
      @debit = @customer.debit(amount:     contribution_amount_in_cents,
                               source_uri: debit_resource_uri,
                               appears_on_statement_as: ::Configuration[:balanced_appears_on_statement_as])
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
  end
end
