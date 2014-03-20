module Neighborly::Balanced
  class EventRegistered
    def confirm(event)
      if event.type.eql? 'bank_account_verification.deposited'
        Notification.notify('confirm_bank_account', event.user)
      end
    end
  end
end
