require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::AccountsController do
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

  describe 'GET new' do
    it 'should fetch balanced customer' do
      expect_any_instance_of(Neighborly::Balanced::Customer).to receive(:fetch).and_return(customer)
      get :new, contribution_id: 42
    end

    it 'should complete the request successfully' do
      get :new, contribution_id: 42
      expect(response.status).to eq 200
    end

    it 'should assign balanced_marketplace_id to view' do
      get :new, contribution_id: 42
      expect(assigns(:balanced_marketplace_id)).to_not be_nil
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
      it 'redirects to user payments page' do
        expect(response).to redirect_to(/users\/(.+)\/payments/)
      end

      it 'set flash message' do
        expect(flash[:success]).to eq 'Your bank account was successfully updated.'
      end
    end

    describe 'insertion of bank account to a customer' do
      let(:customer) { double('::Balanced::Customer').as_null_object }
      let(:bank) do
        double('::Balanced::BankAccount', id: params['payment']['use_bank'])
      end
      before do
        controller.stub(:customer).and_return(customer)
      end

      context "customer doesn't have the given bank" do
        before do
          customer.stub(:bank_accounts).and_return([])
        end

        it "inserts to customer's bank accounts list" do
          expect(customer).to receive(:add_bank_account).with(bank.id)
          post :create, params
        end
      end

      context 'customer already has the bank' do
        before do
          customer.stub(:bank_accounts).and_return([bank])
        end

        it 'skips insertion' do
          expect(customer).to_not receive(:add_bank_account)
          post :create, params
        end
      end

      context 'customer has other bank account' do
        let(:bank) do
          double('::Balanced::BankAccount', id: 'SOME_OLD_ACCOUNT')
        end

        before do
          customer.stub(:bank_accounts).and_return([bank])
        end

        it 'unstores the other bank' do
          expect(customer).to receive(:add_bank_account)
          expect(bank).to receive(:unstore)
          post :create, params
        end
      end
    end
  end
end

