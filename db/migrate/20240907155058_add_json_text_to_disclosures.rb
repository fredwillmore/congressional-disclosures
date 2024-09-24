class AddJsonTextToDisclosures < ActiveRecord::Migration[7.1]
  def change
    add_column :disclosures, :json_text, :jsonb
  end
end
