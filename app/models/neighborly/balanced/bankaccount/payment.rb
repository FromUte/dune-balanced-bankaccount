module Neighborly::Balanced::Bankaccount
  class Payment < PaymentBase
    def checkout!
      @debit  = @customer.debit(amount:     contribution_amount_in_cents,
                                source_uri: @attrs.fetch(:use_bank))
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
  end
end
