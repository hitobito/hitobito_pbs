# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddEventsBsvDays < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :bsv_days, :decimal, scale: 2, precision: 6

    add_column :event_participations, :bsv_days, :decimal, scale: 2, precision: 6
  end
end
