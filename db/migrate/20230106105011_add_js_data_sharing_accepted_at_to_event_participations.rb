#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddJsDataSharingAcceptedAtToEventParticipations < ActiveRecord::Migration[6.1]
  def change
    add_column :event_participations, :j_s_data_sharing_accepted_at, :timestamp, null: true
  end
end
