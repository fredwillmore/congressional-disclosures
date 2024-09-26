class RemoveDocumentFieldsFromDisclosure < ActiveRecord::Migration[7.1]
  def change
    remove_column :disclosures, :document_id
    remove_column :disclosures, :document_text
    remove_column :disclosures, :json_text
  end
end
