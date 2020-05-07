class ChangeEventCampSubmittedToDate < ActiveRecord::Migration[4.2]
  def up
    add_column :events, :camp_submitted_at, :date
    execute("UPDATE events SET camp_submitted_at=created_at WHERE camp_submitted=true")
    remove_column :events, :camp_submitted
  end

  def down
    add_column :events, :camp_submitted, :boolean, null: false, default: false
    execute("UPDATE events SET camp_submitted=true WHERE camp_submitted_at NOT NULL")
    remove_column :events, :camp_submitted_at
  end
end
