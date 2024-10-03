class CreateCongresses < ActiveRecord::Migration[7.1]
  def change
    create_table :congresses do |t|
      t.string :name
      t.integer :start_year
      t.integer :end_year
      t.jsonb :sessions
      t.timestamps
    end
  end
end
