class AddEventKindCampy < ActiveRecord::Migration
  def change
    add_column :event_kinds, :campy, :boolean, null: false, default: false
  end
end
