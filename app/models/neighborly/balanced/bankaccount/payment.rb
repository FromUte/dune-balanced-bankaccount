module Neighborly::Balanced::Bankaccount
  class Payment < PaymentBase
    def checkout!
      debit_params = {
        amount:                  amount_in_cents,
        appears_on_statement_as: ::Configuration[:balanced_appears_on_statement_as],
        description:             debit_description,
        meta:                    meta,
        source_uri:              debit_resource_uri,
      }

      @debit = @customer.debit(debit_params)
      resource.confirm!
    rescue Balanced::BadRequest
      @status = :failed
      resource.cancel!
    ensure
      resource.update_attributes(
        payment_id:                       @debit.try(:id),
        payment_method:                   engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: attrs[:pay_fee]
      )
      update_meta(@debit) if @debit
    end

    def successful?
      %i(pending succeeded).include? status
    end

    def debit_resource_uri
      attrs.fetch(:use_bank) { contributor.bank_account_uri }
    end

    def contributor
      @contributor ||= Neighborly::Balanced::Contributor.find_by(uri: @customer.uri)
    end

    private

    def update_meta(debit)
      debit.meta = meta
      debit.save
    end

    def resource_name
      resource.class.model_name.singular
    end

    def debit_description
      I18n.t('description',
             project_name: resource.try(:project).try(:name),
             scope: "neighborly.balanced.bankaccount.payments.debit.#{resource_name}")
    end

    def meta
      PayableResourceSerializer.new(resource).to_json
    end
  end
end
