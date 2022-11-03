#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class MergeBsvAndTrainingDays < ActiveRecord::Migration[6.0]
  def up
    rename_column:event_participations, :bsv_days, :training_days
    Event.update_all "training_days = bsv_days"
    remove_column :events, :bsv_days
  end

  def down
    rename_column:event_participations, :training_days, :bsv_days
    add_column :events, :bsv_days, :decimal, scale: 2, precision: 6
    Event.update_all "bsv_days = training_days"
  end
end
