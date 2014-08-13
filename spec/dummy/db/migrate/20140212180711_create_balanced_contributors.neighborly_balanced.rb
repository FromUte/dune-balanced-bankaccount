# This migration comes from neighborly_balanced (originally 20140211203335)
class CreateBalancedContributors < ActiveRecord::Migration
  def change
    create_table :balanced_contributors do |t|
      t.references :user, index: true
      t.string :uri

      t.timestamps
    end
  end
end
