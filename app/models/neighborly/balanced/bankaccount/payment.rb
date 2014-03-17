module Neighborly::Balanced::Bankaccount
  class Payment
    def initialize(engine_name, customer, contribution, attrs = {})
      @engine_name  = engine_name
      @customer     = customer
      @contribution = contribution
      @attrs        = attrs
    end

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

    def contribution_amount_in_cents
      (fee_calculator.gross_amount * 100).round
    end

    def fee_calculator
      @fee_calculator and return @fee_calculator

      calculator_class = if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? @attrs[:pay_fee]
                           TransactionAdditionalFeeCalculator
                         else
                           TransactionInclusiveFeeCalculator
                         end

      @fee_calculator = calculator_class.new(@contribution.value)
    end

    def debit
      @debit.try(:sanitize)
    end

    def status
      @debit.try(:status).try(:to_sym) || @status
    end

    def successful?
      %i(pending succeeded).include? status
    end
  end
end
