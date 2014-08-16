class UseHrefsForBalancedResources < ActiveRecord::Migration
  def up
    add_column :balanced_contributors, :href, :string
    add_column :balanced_contributors, :bank_account_href, :string

    fetch_hrefs

    remove_column :balanced_contributors, :uri
    remove_column :balanced_contributors, :bank_account_uri
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fetch_hrefs
    Neighborly::Balanced::Contributor.transaction do
      Neighborly::Balanced::Contributor.all.each do |contributor|
        if contributor.bank_account_uri.present?
          bank_account = Balanced::BankAccount.find(contributor.bank_account_uri)
          contributor.bank_account_href = bank_account.href
        end
        customer = Balanced::Customer.find(contributor.uri)
        contributor.href = customer.href
        status = contributor.save(validate: false)
        Rails.logger.info "Migrated bank_account_href of Contributor ##{contributor.id}. Successful? #{status}"
      end
    end
  end
end
