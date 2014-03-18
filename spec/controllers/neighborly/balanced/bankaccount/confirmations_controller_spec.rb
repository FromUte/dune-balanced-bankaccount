require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::ConfirmationsController do
  routes { Neighborly::Balanced::Bankaccount::Engine.routes }

  let(:current_user) { double('User').as_null_object }
  let(:customer) do
    double('::Balanced::Customer',
           bank_accounts: [double('::Balanced::BankAccount', uid: '/ABANK')],
           uri:           '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
    ::Configuration.stub(:fetch).and_return('SOME_KEY')
    controller.stub(:current_user).and_return(current_user)
  end

  describe 'GET new' do
    it 'should fetch balanced customer' do
      expect_any_instance_of(
        Neighborly::Balanced::Customer
      ).to receive(:fetch).and_return(customer)
      get :new, contribution_id: 42
    end

    it 'should complete the request successfully' do
      get :new, contribution_id: 42
      expect(response.status).to eq 200
    end

    it 'should assign bank_account to view' do
      get :new, contribution_id: 42
      expect(assigns(:bank_account)).to_not be_nil
    end

    it 'should assign customer to view' do
      get :new, contribution_id: 42
      expect(assigns(:customer)).to eq customer
    end
  end
end
