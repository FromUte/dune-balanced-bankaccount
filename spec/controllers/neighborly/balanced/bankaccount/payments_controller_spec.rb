require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::PaymentsController do
  routes { Neighborly::Balanced::Bankaccount::Engine.routes }

  let(:current_user) { double('User').as_null_object }
  let(:customer) do
    double('::Balanced::Customer',
           bank_accounts: [double('::Balanced::BankAccount', id: 'SOME_BANK')],
           uri:           '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
    ::Configuration.stub(:fetch).and_return('SOME_KEY')

    controller.stub(:current_user).and_return(current_user)
  end

  describe 'get new' do
    it 'should use accounts controller new action' do
      expect_any_instance_of(Neighborly::Balanced::Bankaccount::AccountsController).to receive(:new)
      get :new, contribution_id: 42
    end
  end

  describe 'POST create' do
    let(:params) do
      {
        'payment' => {
          'contribution_id' => '42',
          'use_bank'        => 'SOME_BANK',
          'user'            => {}
        },
      }
    end

    context 'successful' do
      before { post :create, params }
      it 'redirects to contribute page' do
        expect(response).to redirect_to('/projects/forty-two/contributions/42')
      end
    end

    describe 'insertion of bank account to a customer' do
      it 'should use accounts controller attach_bank_to_customer method' do
        expect_any_instance_of(Neighborly::Balanced::Bankaccount::AccountsController).to receive(:attach_bank_to_customer)
        post :create, params
      end
    end

    describe 'update customer' do
      it 'update user attributes and balanced customer' do
        expect_any_instance_of(Neighborly::Balanced::Customer).to receive(:update!)
        post :create, params
      end
    end
  end
end
