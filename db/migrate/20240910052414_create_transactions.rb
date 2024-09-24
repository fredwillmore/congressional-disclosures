class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.integer :disclosure_id
      t.index [:disclosure_id], name: "index_transactions_on_disclosure_id"
      t.date :date
      t.string :asset
      t.integer :owner
      t.integer :amount
      t.integer :transaction_type
      t.timestamps
    end
  end
end
