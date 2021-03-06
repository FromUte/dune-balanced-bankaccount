require 'spec_helper'

describe Dune::Balanced::Bankaccount::Payment do
  shared_examples_for 'payable' do
    let(:customer)     { double('::Balanced::Customer', href: '/CUSTOMER-ID') }
    let(:debit)        { double('::Balanced::Debit').as_null_object }
    let(:bank_account) { double('::Balanced::BankAccount', href: '/ABANK') }
    let(:attributes)   { { use_bank: bank_account.href } }
    subject do
      described_class.new('balanced-bankaccount',
                          customer,
                          resource,
                          attributes)
    end
    before do
      Balanced::BankAccount.stub(:find).with(bank_account.href).
        and_return(bank_account)
      subject.stub_chain(:contributor, :projects).and_return([])

      User.any_instance.stub(:balanced_contributor).and_return(
        double('BalancedContributor', href: 'project-owner-href')
      )

      allow_any_instance_of(Dune::Balanced::OrderProxy).to receive(:debit_from).and_return(debit)
      resource.stub(:value).and_return(1234)
      described_class.any_instance.stub(:meta).and_return({})
    end

    describe '#amount_in_cents' do
      context 'when customer is paying fees' do
        let(:attributes) { { pay_fee: '1', use_bank: bank_account.href } }

        it 'returns gross amount from TransactionAdditionalFeeCalculator' do
          Dune::Balanced::Bankaccount::TransactionAdditionalFeeCalculator.
            any_instance.stub(:gross_amount).and_return(15)
          expect(subject.amount_in_cents).to eql(1500)
        end
      end

      context 'when customer is not paying fees' do
        let(:attributes) { { pay_fee: '0', use_bank: bank_account.href } }

        it 'returns gross amount from TransactionInclusiveFeeCalculator' do
          Dune::Balanced::Bankaccount::TransactionInclusiveFeeCalculator.
            any_instance.stub(:gross_amount).and_return(10)
          expect(subject.amount_in_cents).to eql(1000)
        end
      end
    end

    describe 'checkout' do
      shared_examples 'updates resource object' do
        let(:attributes)  { { pay_fee: '1', use_bank: bank_account.href } }

        context 'when a use_bank is provided' do
          before do
            allow(Balanced::BankAccount).to receive(:find).
              with(bank_account.href).and_return(bank_account)
          end

          it 'debits customer on selected funding instrument' do
            expect_any_instance_of(
              Dune::Balanced::OrderProxy
            ).to receive(:debit_from).with(hash_including(source: bank_account)).
              and_return(debit)
            subject.checkout!
          end
        end

        context 'when no use_bank is provided' do
          let(:contributor) do
            double('Dune::Balanced::Contributor',
              bank_account_href: '/MY-DEFAULT-BANK',
              projects:         []
            )
          end
          let(:attributes) { { pay_fee: '1' } }
          before do
            subject.stub(:contributor).and_return(contributor)
            allow(Balanced::BankAccount).to receive(:find).
              with(contributor.bank_account_href).and_return(bank_account)
          end

          it 'debits customer on default funding instrument' do
            expect_any_instance_of(
              Dune::Balanced::OrderProxy
            ).to receive(:debit_from).with(hash_including(source: bank_account)).
              and_return(debit)
            subject.checkout!
          end
        end

        it 'defines given engine\'s name as payment method of the resource' do
          resource.should_receive(:update_attributes).
                       with(hash_including(payment_method: 'balanced-bankaccount'))
          subject.checkout!
        end

        it 'saves paid fees on resource object' do
          calculator = double('FeeCalculator', fees: 0.42).as_null_object
          subject.stub(:fee_calculator).and_return(calculator)
          resource.should_receive(:update_attributes).
                       with(hash_including(payment_service_fee: 0.42))
          subject.checkout!
        end

        it 'saves who paid the fees' do
          calculator = double('FeeCalculator', fees: 0.42).as_null_object
          subject.stub(:fee_calculator).and_return(calculator)
          resource.should_receive(:update_attributes).
                       with(hash_including(payment_service_fee_paid_by_user: '1'))
          subject.checkout!
        end
      end

      context 'with successful debit' do
        before do
          allow_any_instance_of(
            Dune::Balanced::OrderProxy
          ).to receive(:debit_from).and_return(debit)
        end

        include_examples 'updates resource object'

        it 'confirms the resource' do
          expect(resource).to receive(:confirm)
          subject.checkout!
        end

        it 'defines appears_on_statement_as on debit' do
          ::Configuration.stub(:[]).with(:balanced_appears_on_statement_as).
            and_return('www.dune-investissement.fr')

          expect_any_instance_of(
            Dune::Balanced::OrderProxy
          ).to receive(:debit_from).with(hash_including(appears_on_statement_as: 'dune-investissement')).
            and_return(debit)
          subject.checkout!
        end

        it 'defines id as payment id of the resource' do
          debit.stub(:id).and_return('i-am-an-id!')
          resource.should_receive(:update_attributes).
                       with(hash_including(payment_id: 'i-am-an-id!'))
          subject.checkout!
        end

        it 'defines meta on debit' do
          described_class.any_instance.stub(:meta).and_return({ payment_service_fee: 5.0 })
          expect_any_instance_of(
            Dune::Balanced::OrderProxy
          ).to receive(:debit_from).with(hash_including(meta: { payment_service_fee: 5.0 })).
            and_return(debit)
          subject.checkout!
        end
      end

      context 'when raising Balanced::BadRequest exception' do
        before do
          allow_any_instance_of(
            Dune::Balanced::OrderProxy
          ).to receive(:debit_from).
            and_raise(Balanced::BadRequest.new({}))
        end

        include_examples 'updates resource object'

        it 'cancels the resource' do
          expect(resource).to receive(:cancel)
          subject.checkout!
        end
      end

      context 'when a description is provided to debit' do
        it 'defines description on debit' do
          Project.any_instance.stub(:name).and_return('Awesome Project')
          expect_any_instance_of(
            Dune::Balanced::OrderProxy
          ).to receive(:debit_from).with(hash_including(description: debit_description)).
            and_return(debit)
          subject.checkout!
        end
      end
    end

    describe 'status' do
      context 'after checkout' do
        before do
          subject.checkout!
        end

        it 'returns the debit status symbolized' do
          debit.stub(:status).and_return('my_status')
          expect(subject.status).to eql(:my_status)
        end
      end

      context 'before checkout' do
        it 'is nil' do
          expect(subject.status).to be_nil
        end
      end
    end

    describe 'successful state' do
      before do
        allow_any_instance_of(
          Dune::Balanced::OrderProxy
        ).to receive(:debit_from).and_return(debit)
      end

      context 'after checkout' do
        before { subject.checkout! }

        it 'is successfull when the debit has \'succeeded\' status' do
          debit.stub(:status).and_return('succeeded')
          expect(subject).to be_successful
        end

        it 'is successfull when the debit has \'pending\' status' do
          debit.stub(:status).and_return('pending')
          expect(subject).to be_successful
        end

        it 'is not successfull when the debit has others statuses' do
          debit.stub(:status).and_return('failed')
          expect(subject).to_not be_successful
        end
      end

      context 'before checkout' do
        it 'is not successfull' do
          expect(subject).to_not be_successful
        end
      end
    end
  end

  context 'when resource is Contribution' do
    let(:resource)          { FactoryGirl.create(:contribution) }
    let(:debit_description) { 'Contribution to Awesome Project' }

    it_should_behave_like 'payable'
  end

  context 'when resource is Match' do
    let(:resource)          { FactoryGirl.create(:match) }
    let(:debit_description) { 'Match for Awesome Project' }

    it_should_behave_like 'payable'
  end
end
