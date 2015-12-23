class ChangeCampLocationFields < ActiveRecord::Migration
  def change
    rename_column :events, :camp_location, :canton
    change_column :events, :canton, :string, limit: 2
    remove_column :events, :camp_location_address
    rename_column :events, :camp_location_coordinates, :coordinates
    rename_column :events, :camp_location_altitude, :altitude
    rename_column :events, :camp_location_emergency_phone, :emergency_phone
    rename_column :events, :camp_location_owner, :landlord
    change_column :events, :landlord, :text
    rename_column :events, :camp_location_approved, :landlord_permission_obtained
  end
end
