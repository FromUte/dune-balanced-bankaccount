module Dune::Balanced::Bankaccount
  class DelayedPaymentProcessing
    def initialize(contributor, resources)
      @contributor, @resources = contributor, resources
    end

    def complete
      @resources.each do |resource|
        Dune::Balanced::Bankaccount::Payment.new(
          'balanced-bankaccount',
          customer,
          resource,
          {}
        ).checkout!
      end
    end

    def customer
      @customer ||= ::Balanced::Customer.find(@contributor.href)
    end
  end
end
