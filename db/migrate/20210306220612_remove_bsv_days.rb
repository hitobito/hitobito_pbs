#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class RemoveBsvDays < ActiveRecord::Migration[6.0]
  def up
    add_column :event_participations, :training_days, :decimal, scale: 2, precision: 6
    #TODO: copy values from :bsv_days to :training_days
    remove_column :event_participations, :bsv_days
    remove_column :events, :bsv_days
  end

  def down
    remove_column :event_participations, :training_days
    #TODO: copy values from :training_days to :bsv_days
    add_column :events, :bsv_days, :decimal, scale: 2, precision: 6
    add_column :event_participations, :bsv_days, :decimal, scale: 2, precision: 6
  end
end
