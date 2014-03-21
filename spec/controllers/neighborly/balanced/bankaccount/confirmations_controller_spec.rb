require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::ConfirmationsController do
  routes { Neighborly::Balanced::Bankaccount::Engine.routes }

  let(:current_user) { double('User').as_null_object }
  let(:verification) { double('::Balanced::Verification', state: 'unverified') }
  let(:customer) do
    double('::Balanced::Customer',
           bank_accounts: [double('::Balanced::BankAccount', uid: '/ABANK',
                                  verifications: [verification]
                                 )],
           uri:           '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
    ::Configuration.stub(:fetch).and_return('SOME_KEY')
    controller.stub(:authenticate_user!)
    controller.stub(:current_user).and_return(current_user)
  end

  describe 'GET new' do
    it 'should receive authenticate_user!' do
      expect(controller).to receive(:authenticate_user!)
      get :new
    end

    context 'when user has a bank account' do
      it 'should fetch balanced customer' do
        expect_any_instance_of(
          Neighborly::Balanced::Customer
        ).to receive(:fetch).and_return(customer)
        get :new
      end

      it 'should render application layout' do
        get :new
        expect(response).to render_template(layout: 'application')
      end

      it 'should complete the request successfully' do
        get :new
        expect(response.status).to eq 200
      end

      it 'should assign bank_account to view' do
        get :new
        expect(assigns(:bank_account)).to_not be_nil
      end

      it 'should assign contributions to view' do
        contributions = [double('Contribution')]
        current_user.contributions.stub(:with_state).and_return(contributions)
        get :new
        expect(assigns(:contributions)).to eq(contributions)
      end

      it 'should assign customer to view' do
        get :new
        expect(assigns(:customer)).to eq customer
      end
    end

    context 'when user do not have a bank account' do
      before { customer.stub(:bank_accounts).and_return([]) }

      it 'should redirect to user payments page' do
        get :new
        expect(response).to redirect_to(/users\/(.+)\/payments/)
      end

      it 'should set a flash message' do
        get :new
        expect(flash.alert).to eq "You don't have any bank account to confirm, please add one."
      end
    end

    context 'when user has a bank account already confirmed' do
      let(:verification) { double('::Balanced::Verification', state: 'verified') }

      it 'should redirect to user payments page' do
        get :new
        expect(response).to redirect_to(/users\/(.+)\/payments/)
      end

      it 'should set a flash message' do
        get :new
        expect(flash.alert).to eq 'Your Bank Account was already confirmed.'
      end
    end
  end
end
