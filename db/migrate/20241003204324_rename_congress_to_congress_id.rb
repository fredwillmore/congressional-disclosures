class RenameCongressToCongressId < ActiveRecord::Migration[7.1]
  def change
    remove_column :terms, :congress
    add_column :terms, :congress_id, :integer
  end
end
