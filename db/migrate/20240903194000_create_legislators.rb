class CreateLegislators < ActiveRecord::Migration[7.1]
  def change
    create_table :legislators do |t|
      # TODO: need to support representatives changing districts
      t.string :bioguide_id
      # t.string :status
      t.string :prefix
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.integer :birth_year

      t.timestamps
    end
  end
end
