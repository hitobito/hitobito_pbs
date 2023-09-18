class AddAlumniProcessingTimestampsToRole < ActiveRecord::Migration[6.1]
  def up
    add_column :groups, :alumni_invitation_processed_at, :datetime, null: true
    add_column :groups, :alumni_reminder_processed_at, :datetime, null: true

    connection.execute <<~SQL
      UPDATE groups
      SET alumni_invitation_processed_at = NOW(), alumni_reminder_processed_at = NOW()
      WHERE deleted_at < NOW()
    SQL
  end

  def down
    remove_column :groups, :alumni_reminder_processed_at
    remove_column :groups, :alumni_invitation_processed_at
  end
end
