class CreateDisclosures < ActiveRecord::Migration[7.1]
  def change
    create_table :disclosures do |t|
      t.integer :legislator_id, null: false
      t.index [:legislator_id], name: "index_disclosures_on_representative_id"
      t.integer :filing_type_id, null: false
      t.index [:filing_type_id], name: "index_disclosures_on_filing_type_id"
      t.integer :state_id, null: false
      t.index [:state_id], name: "index_disclosures_on_state_id"
      t.integer :district
      t.integer :year
      t.date :filing_date
      t.string :document_id
      t.string :document_text
      t.boolean :image_pdf

      t.timestamps
    end
  end
end
