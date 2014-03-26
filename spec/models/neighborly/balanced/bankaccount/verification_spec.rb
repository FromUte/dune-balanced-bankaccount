require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::Verification do
  let(:balanced_verification) { double('Balanced::Verification', id: 'VERIFICATION-ID') }
  let(:user)                  { double('User') }
  let(:contributor) do
    double('Neighborly::Balanced::Contributor', user: user)
  end
  subject { described_class.new(balanced_verification) }

  describe 'user' do
    it 'gets the user related to the contributor of the verification' do
      bank_account_uri = '/ABANK'
      Neighborly::Balanced::Contributor.stub(:find_by).
        with(bank_account_uri: bank_account_uri).
        and_return(contributor)
    end
  end

  describe 'confirmation' do
    it 'performs call to Bankaccount::DebitAuthorizedContributionsWorker' do
      expect(
        Neighborly::Balanced::Bankaccount::DebitAuthorizedContributionsWorker
      ).to receive(:perform_async).with(balanced_verification.id)
      subject.confirm
    end
  end
end
