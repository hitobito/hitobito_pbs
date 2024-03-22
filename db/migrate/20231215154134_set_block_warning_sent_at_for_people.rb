# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class SetBlockWarningSentAtForPeople < ActiveRecord::Migration[6.1]
  def up
    connection.execute <<~SQL
      UPDATE people
      SET inactivity_block_warning_sent_at = #{connection.quote(Time.zone.now)}
      WHERE blocked_at IS NULL
      AND last_sign_in_at < #{connection.quote(18.months.ago)}
    SQL
  end
end
