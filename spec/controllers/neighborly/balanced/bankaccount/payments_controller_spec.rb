require 'spec_helper'

describe Neighborly::Balanced::Bankaccount::PaymentsController do
  routes { Neighborly::Balanced::Bankaccount::Engine.routes }

  describe "GET 'new'" do
    let(:current_user) { double('User').as_null_object }
    before do
      controller.stub(:current_user).and_return(current_user)
    end

    it 'request should be successfuly' do
      get :new, contribution_id: 42
      expect(response.status).to eq 200
    end
  end
end
