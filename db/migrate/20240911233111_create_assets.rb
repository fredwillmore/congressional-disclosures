class CreateAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :assets do |t|
      t.integer :disclosure_id
      t.index [:disclosure_id], name: "index_assets_on_disclosure_id"
      t.string :asset
      t.string :owner
      t.integer :asset_value
      t.string :income
      # t.string :tax_over_1000
      
      t.timestamps
    end
  end
end
