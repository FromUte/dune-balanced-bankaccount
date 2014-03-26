module Neighborly::Balanced::Bankaccount
  class Verification
    delegate :user, to: :contributor

    def self.find(uri)
      new(::Balanced::Verification.find(uri))
    end

    def initialize(balanced_verification)
      @source = balanced_verification
    end

    def bank_account
      ::Balanced::BankAccount.find(bank_account_uri)
    end

    def bank_account_uri
      uri.match(/\A(?<bank_account_uri>.+)\/verifications/)[:bank_account_uri]
    end

    def contributor
      Contributor.find_by(bank_account_uri: bank_account_uri)
    end

    def confirm
      DebitAuthorizedContributionsWorker.perform_async(self.id)
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
