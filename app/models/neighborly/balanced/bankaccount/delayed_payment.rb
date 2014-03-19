module Neighborly::Balanced::Bankaccount
  class DelayedPayment < PaymentBase
    def checkout!
      @contribution.authorize_payment! and @status = :succeeded
    end

    def successful?
      @status.eql? :succeeded
    end
  end
end
