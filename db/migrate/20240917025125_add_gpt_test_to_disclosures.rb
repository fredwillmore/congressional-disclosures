class AddGptTestToDisclosures < ActiveRecord::Migration[7.1]
  def change
    add_column :disclosures, :gpt_test, :boolean
  end
end
