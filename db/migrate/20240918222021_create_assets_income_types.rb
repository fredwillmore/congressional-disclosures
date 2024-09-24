class CreateAssetsIncomeTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :assets_income_types do |t|
      t.integer :asset_id
      t.integer :income_type_id
      t.timestamps
    end
  end
end
