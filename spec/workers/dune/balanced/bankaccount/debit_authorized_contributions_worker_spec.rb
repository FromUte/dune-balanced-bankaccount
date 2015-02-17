require 'spec_helper'

describe Dune::Balanced::Bankaccount::DebitAuthorizedContributionsWorker do
  let(:contributor) { double('Contributor', id: 45, user_id: user.id, user: user) }
  let(:user)        { double('User', id: 42) }

  before do
    Dune::Balanced::Contributor.stub(:find).and_return(contributor)
  end

  describe 'performation' do
    let(:contributions) do
      [double('Contribution', state: :confirmed, user_id: user.id)]
    end

    let(:payment_processing) do
      double('DelayedPaymentProcessing')
    end

    before do
      subject.stub(:resources_waiting_confirmation_for).
              and_return(contributions)
    end

    it 'completes payments of all contributions waiting confirmation' do
      Dune::Balanced::Bankaccount::DelayedPaymentProcessing.
        stub(:new).
        with(contributor, contributions).
        and_return(payment_processing)
      expect(payment_processing).to receive(:complete)
      subject.perform(contributor.id)
    end
  end

  describe '#resources_waiting_confirmation_for' do
    before do
      user.stub_chain(:contributions, :with_state, :where).and_return(contributions)
      user.stub_chain(:matches, :with_state, :where).and_return(matches)
    end

    let(:contribution) { double('Contribution', state: :confirmed) }
    let(:match)        { double('Projects::Match', state: :confirmed) }

    context 'when has just a contribution' do
      let(:contributions) { [contribution] }
      let(:matches)       { [] }

      it 'returns resources waiting confirmation for given user' do
        expect(subject.resources_waiting_confirmation_for(user)).to eq [contribution]
      end
    end

    context 'when has just a match' do
      let(:contributions) { nil }
      let(:matches)       { [match] }

      it 'returns resources waiting confirmation for given user' do
        expect(subject.resources_waiting_confirmation_for(user)).to eq [match]
      end
    end

    context 'when has matches and contributions' do
      let(:contributions) { [contribution] }
      let(:matches)       { [match] }

      it 'returns resources waiting confirmation for given user' do
        expect(subject.resources_waiting_confirmation_for(user)).to eq [contribution, match]
      end
    end
  end
end
