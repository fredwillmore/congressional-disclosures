class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :external_id # was document_id on disclosures
      t.integer :disclosure_id
      t.string :document_text # was document_text on disclosures
      t.jsonb :document_json # was json_text on disclosures
      t.timestamps
    end
  end
end
