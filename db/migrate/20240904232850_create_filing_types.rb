class CreateFilingTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :filing_types do |t|
      t.string :name
      t.string :abbreviation
      t.timestamps
    end
  end
end
