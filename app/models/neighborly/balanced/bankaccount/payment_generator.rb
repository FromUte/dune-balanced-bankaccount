module Neighborly::Balanced::Bankaccount
  class PaymentGenerator
    attr_reader :attrs, :contribution, :customer

    delegate :status, to: :payment

    def initialize(customer, contribution, attrs = {})
      @customer      = customer
      @contribution  = contribution
      @attrs         = attrs
    end

    def complete
      payment.checkout!
    end

    def payment
      @payment ||= payment_class.new(
        'balanced-bankaccount',
        customer,
        contribution,
        attrs
      )
    end

    def payment_class
      @payment_class ||= if can_debit_resource?
        Neighborly::Balanced::Bankaccount::Payment
      end
    end

    protected

    def can_debit_resource?
      true
    end
  end
end
