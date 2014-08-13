module Neighborly::Balanced::Bankaccount
  class PaymentGenerator
    attr_reader :attrs, :resource, :customer

    delegate :status, to: :payment

    def initialize(customer, resource, attrs = {})
      @customer      = customer
      @resource      = resource
      @attrs         = attrs
    end

    def complete
      payment.checkout!
    end

    def payment
      @payment ||= payment_class.new(
        'balanced-bankaccount',
        customer,
        resource,
        attrs
      )
    end

    def payment_class
      @payment_class ||= can_debit_resource? ? Neighborly::Balanced::Bankaccount::Payment : Neighborly::Balanced::Bankaccount::DelayedPayment
    end

    def can_debit_resource?
      debit_resource.bank_account_verifications.to_a.first.try(:state).eql? 'verified'
    end

    def debit_resource
      @debit_resource ||= ::Balanced::BankAccount.find(@attrs.fetch(:use_bank))
    end
  end
end
