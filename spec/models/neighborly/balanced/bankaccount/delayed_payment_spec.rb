require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::DelayedPayment do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', value: 1234).as_null_object }
  let(:bank_account) { double('::Balanced::BankAccount', uri: '/ABANK') }
  let(:attributes)   { { use_bank: bank_account.uri } }
  subject do
    described_class.new('balanced-bankaccount',
                        customer,
                        contribution,
                        attributes)
  end

  describe 'checkout' do
    it 'authorizes payment of contribution' do
      expect(contribution).to receive(:authorize_payment!)
      subject.checkout!
    end
  end

  describe 'status' do
    context 'after checkout' do
      before do
        subject.checkout!
      end

      it 'is succeeded' do
        expect(subject.status).to eql(:succeeded)
        expect(subject).to        be_successful
      end
    end

    context 'before checkout' do
      it 'is nil' do
        expect(subject.status).to be_nil
      end

      it 'is not succeeded' do
        expect(subject).to_not be_successful
      end
    end
  end
end
