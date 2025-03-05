# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddAlumniProcessingTimestampsToRole < ActiveRecord::Migration[6.1]
  def up
    add_column :roles, :alumni_invitation_processed_at, :datetime, null: true
    add_column :roles, :alumni_reminder_processed_at, :datetime, null: true

    if /sqlite/.match?(connection.adapter_name.downcase)
      connection.execute <<~SQL
        UPDATE roles
        SET alumni_invitation_processed_at = '1970-01-01', alumni_reminder_processed_at = '1970-01-01'
        WHERE end_on < TIME('now')
      SQL
    else
      connection.execute <<~SQL
        UPDATE roles
        SET alumni_invitation_processed_at = '1970-01-01', alumni_reminder_processed_at = '1970-01-01'
        WHERE end_on < NOW()
      SQL
    end
  end

  def down
    remove_column :roles, :alumni_reminder_processed_at
    remove_column :roles, :alumni_invitation_processed_at
  end
end
