class CreateTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :terms do |t|
      t.integer :legislator_id
      t.string :chamber
      t.integer :congress
      t.integer :state_id
      t.integer :district
      t.integer :start_year
      t.integer :end_year
      t.string :member_type
      t.timestamps
    end
  end
end
