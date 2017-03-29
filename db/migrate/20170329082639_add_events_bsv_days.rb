class AddEventsBsvDays < ActiveRecord::Migration
  def change
    add_column :events, :bsv_days, :decimal, scale: 2, precision: 6

    add_column :event_participations, :bsv_days, :decimal, scale: 2, precision: 6
  end
end
