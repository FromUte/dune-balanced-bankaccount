module Neighborly::Balanced::Bankaccount
  class Verification
    delegate :user, to: :contributor

    def self.find(href)
      new(::Balanced::Verification.find(href))
    end

    def initialize(balanced_verification)
      @source = balanced_verification
    end

    def bank_account_href
      bank_account.href
    end

    def contributor
      Neighborly::Balanced::Contributor.find_by(bank_account_href: bank_account_href)
    end

    def confirm
      DebitAuthorizedContributionsWorker.perform_async(contributor.id)
    end

    # Delegate instance methods to Balanced::Verification object
    def method_missing(method, *args, &block)
      if @source.respond_to? method
        @source.public_send(method, *args, &block)
      else
        super
      end
    end
  end
end
