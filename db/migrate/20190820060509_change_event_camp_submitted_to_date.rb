class ChangeEventCampSubmittedToDate < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :events, :camp_submitted_at, :date
        execute("UPDATE events SET camp_submitted_at=created_at WHERE camp_submitted=true")
        remove_column :events, :camp_submitted
      end

      dir.down do
        add_column :events, :camp_submitted, :boolean, null: false, default: false
        execute("UPDATE events SET camp_submitted=true WHERE camp_submitted_at NOT NULL")
        remove_column :events, :camp_submitted_at
      end
    end
  end
end
