class AddCampSubmittedAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :camp_submitted_at, :date
  end
end
