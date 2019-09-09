class AddGroupFinderFields < ActiveRecord::Migration
  def up
    add_column :groups, :gender, :string, limit: 1
    add_column :groups, :try_out_day_at, :date

    create_table :geolocations do |t|
      t.string :lat
      t.string :long
      t.references :geolocatable, polymorphic: true
      t.timestamps null: false
    end
  end

  def down
    drop_table :geolocations

    remove_column :groups, :try_out_day_at
    remove_column :groups, :gender
  end
end
