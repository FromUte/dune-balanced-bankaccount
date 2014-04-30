require 'sidekiq'

module Neighborly::Balanced::Bankaccount
  class DebitAuthorizedContributionsWorker
    include Sidekiq::Worker
    sidekiq_options retry: true

    def perform(contributor_id)
      contributor = Neighborly::Balanced::Contributor.find(contributor_id)
      DelayedPaymentProcessing.new(
        contributor,
        resources_waiting_confirmation_for(contributor.user)
      ).complete
    end

    def resources_waiting_confirmation_for(user)
      resources = user.contributions.with_state(:waiting_confirmation).
        where(payment_method: 'balanced-bankaccount') || []

      resources.concat user.matches.with_state(:waiting_confirmation).
        where(payment_method: 'balanced-bankaccount')

      resources
    end
  end
end
