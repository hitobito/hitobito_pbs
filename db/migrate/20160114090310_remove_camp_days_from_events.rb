class RemoveCampDaysFromEvents < ActiveRecord::Migration[4.2]
  def change
    remove_column :events, :camp_days
  end
end
