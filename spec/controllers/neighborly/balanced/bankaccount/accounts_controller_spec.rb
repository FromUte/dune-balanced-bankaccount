require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::AccountsController do
  routes { Neighborly::Balanced::Bankaccount::Engine.routes }

  let(:current_user) { double('User', id: 42).as_null_object }

  let(:bank_account) do
    double('::Balanced::BankAccount', href: '/ABANK').as_null_object
  end

  let(:customer) do
    double('::Balanced::Customer',
           bank_accounts: [bank_account],
           href:           '/qwertyuiop').as_null_object
  end


  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
    ::Balanced::BankAccount.stub(:fetch).and_return(bank_account)
    ::Configuration.stub(:fetch).and_return('SOME_KEY')
    Notification.stub(:notify)
    controller.stub(:authenticate_user!)
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

    it 'should assign bank_account to view' do
      get :new, contribution_id: 42
      expect(assigns(:bank_account)).to_not be_nil
    end

    it 'should assign customer to view' do
      get :new, contribution_id: 42
      expect(assigns(:customer)).to eq customer
    end

    it 'should receive authenticate_user!' do
      expect(controller).to receive(:authenticate_user!)
      get :new
    end
  end

  describe 'POST create' do
    let(:params) do
      {
        'payment' => {
          'contribution_id' => '42',
          'use_bank'        => '/ABANK',
          'user'            => {}
        },
      }
    end

    it 'should receive authenticate_user!' do
      expect(controller).to receive(:authenticate_user!)
      post :create, params
    end

    context 'successful' do
      before { post :create, params }
      it 'redirects to user payments page' do
        expect(response).to redirect_to(/users\/(.+)\/payments/)
      end

      it 'set flash message' do
        expect(flash[:success]).to eq 'Bank account successfully updated. We have started a new verification process, please check your email for next steps.'
      end
    end

    describe 'insertion of bank account to a customer' do
      let(:contributor) do
          double('Neighborly::Balanced::Contributor').as_null_object
        end
      let(:customer) { double('::Balanced::Customer').as_null_object }
      let(:bank) do
        double('::Balanced::BankAccount', href: params['payment']['use_bank']).as_null_object
      end

      before do
        controller.stub(:customer).and_return(customer)
        Neighborly::Balanced::Contributor.stub(:find_or_create_by).
          and_return(contributor)
      end

      context "customer doesn't have the given bank" do
        before do
          customer.stub(:bank_accounts).and_return([])
        end

        it "inserts to customer's bank accounts list" do
          expect(bank_account).to receive(:associate_to_customer).with(customer)
          post :create, params
        end

        it 'skips notification to user about replaced bank account' do
          expect(Notification).not_to receive(:notify)
          post :create, params
        end

        it 'creates a Balanced::Contributor for the user' do
          expect(
            Neighborly::Balanced::Contributor
          ).to receive(:find_or_create_by).
                 with(user_id: current_user.id).
                 and_return(contributor)
          post :create, params
        end

        it 'updates Balanced::Contributor\'s bank_account_href' do
          expect(
            contributor
          ).to receive(:update_attributes).with(bank_account_href: '/ABANK')
          post :create, params
        end
      end

      context 'customer already has the bank' do
        before do
          customer.stub(:bank_accounts).and_return([bank])
        end

        it 'skips insertion' do
          expect(bank_account).to_not receive(:associate_to_customer)
          post :create, params
        end
      end

      context 'customer has other bank account' do
        let(:bank) do
          double('::Balanced::BankAccount', href: '/OLD_BANK').as_null_object
        end

        before do
          customer.stub(:bank_accounts).and_return([bank])
        end

        it 'unstores the other bank' do
          expect(bank_account).to receive(:associate_to_customer)
          expect(bank).to receive(:unstore)
          post :create, params
        end

        it 'updates Balanced::Contributor\'s bank_account_href' do
          expect(
            contributor
          ).to receive(:update_attributes).with(bank_account_href: '/ABANK')
          post :create, params
        end

        it 'notify user about replaced bank account' do
          expect(Notification).to receive(:notify).
            with('balanced/bankaccount/bank_account_replaced', anything)
          post :create, params
        end
      end

      context 'start bank account verification' do
        before do
          customer.stub(:bank_accounts).and_return([])
        end

        it 'should start the bank account verification' do
          expect(bank_account).to receive(:verify)
          post :create, params
        end
      end
    end
  end
end

