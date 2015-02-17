require 'spec_helper'

describe Dune::Balanced::Bankaccount::PaymentGenerator do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', value: 1234).as_null_object }
  let(:attrs)        { { use_bank: '/ABANK' } }
  let(:bank_account) { double('::Balanced::BankAccount', bank_account_verifications: []) }
  subject { described_class.new(customer, contribution, attrs) }

  before do
    ::Balanced::BankAccount.stub(:find).and_return(bank_account)
  end

  describe 'ability to debit resource' do
    before do
      bank_account.stub(:bank_account_verifications).and_return(verifications)
    end

    context 'with confirmed verification' do
      let(:verifications) do
        [double('::Balanced::BankAccountVerification', verification_status: 'succeeded')]
      end

      it 'is able to debit resource' do
        expect(subject.can_debit_resource?).to be_truthy
      end
    end

    context 'with verification started' do
      let(:verifications) do
        [double('::Balanced::BankAccountVerification', state: 'deposit_succeeded')]
      end

      it 'isn\'t able to debit resource' do
        expect(subject.can_debit_resource?).to be_falsey
      end
    end

    context 'without verifications' do
      let(:verifications) { [] }

      it 'isn\'t able to debit resource' do
        expect(subject.can_debit_resource?).to be_falsey
      end
    end
  end

  describe 'completion' do
    it 'checkouts using Payment class when is able to debit resource' do
      subject.stub(:can_debit_resource?).and_return(true)
      expect_any_instance_of(
        Dune::Balanced::Bankaccount::Payment
      ).to receive(:checkout!)
      subject.complete
    end

    it 'checkouts using DelayedPayment when is not able to debit resource' do
      subject.stub(:can_debit_resource?).and_return(false)
      expect_any_instance_of(
        Dune::Balanced::Bankaccount::DelayedPayment
      ).to receive(:checkout!)
      subject.complete
    end
  end
end
