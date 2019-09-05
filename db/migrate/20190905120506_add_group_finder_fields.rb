class AddGroupFinderFields < ActiveRecord::Migration
  def up
    add_column :groups, :gender, :string, limit: 1
    add_column :groups, :try_out_day_at, :date

    create_table :group_coordinates do |t|
      t.string :lat
      t.string :long
      t.belongs_to :group
      t.timestamps
    end
  end

  def down
    drop_table :group_coordinates

    remove_column :groups, :try_out_day_at
    remove_column :groups, :gender
  end
end
