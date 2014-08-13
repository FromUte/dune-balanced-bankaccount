# This migration comes from neighborly_balanced_bankaccount (originally 20140813180429)
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
      Neighborly::Balanced::Contributor.all.each do |customer|
        bank_account = Balanced::BankAccount.find(customer.bank_account_uri)
        customer.bank_account_href = bank_account.href
        customer.href = bank_account.customer.href
        customer.save(validate: false)
      end
    end
  end
end
