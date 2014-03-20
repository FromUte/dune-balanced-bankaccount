require 'spec_helper'

describe Neighborly::Balanced::EventRegistered do
  let(:user) { double('User') }
  let(:event) do
    double('Neighborly::Balanced::Event', user: user)
  end

  describe 'confirmation' do
    context 'with \'bank_account_verification.deposited\' event' do
      before do
        event.stub(:type).and_return('bank_account_verification.deposited')
      end

      it 'generates \'confirm_bank_account\' notification' do
        expect(Notification).to receive(:notify).
          with('confirm_bank_account', anything)
        subject.confirm(event)
      end
    end

    context 'with other types of events' do
      before do
        event.stub(:type).and_return('bank_account_verification.created')
      end

      it 'skips generation of notifications' do
        expect(Notification).to_not receive(:notify)
        subject.confirm(event)
      end
    end
  end
end
