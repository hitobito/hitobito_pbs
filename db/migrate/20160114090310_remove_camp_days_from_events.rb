class RemoveCampDaysFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :camp_days
  end
end
