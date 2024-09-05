class CreatePartyAffiliations < ActiveRecord::Migration[7.1]
  def change
    create_table :party_affiliations do |t|
      t.integer :legislator_id
      t.integer :party_id
      t.integer :start_year
      t.integer :end_year
      t.timestamps
    end
  end
end
