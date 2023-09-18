# frozen_string_literal: true

class AddAlumniProcessingTimestampsToRole < ActiveRecord::Migration[6.1]
  def up
    add_column :roles, :alumni_invitation_processed_at, :datetime, null: true
    add_column :roles, :alumni_reminder_processed_at, :datetime, null: true

    connection.execute <<~SQL
      UPDATE roles
      SET alumni_invitation_processed_at = '1970-01-01', alumni_reminder_processed_at = '1970-01-01'
      WHERE deleted_at < NOW()
    SQL
  end

  def down
    remove_column :roles, :alumni_reminder_processed_at
    remove_column :roles, :alumni_invitation_processed_at
  end
end
