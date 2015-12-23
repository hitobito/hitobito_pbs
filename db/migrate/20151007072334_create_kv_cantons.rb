# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CreateKvCantons < ActiveRecord::Migration
  def change
    create_table :kantonalverband_cantons do |t|
      t.integer :kantonalverband_id, null: false
      t.string :canton, null: false, limit: 2
    end

    add_index :kantonalverband_cantons, [:kantonalverband_id, :canton], unique: true

    add_column :events, :camp_reminder_sent, :boolean, null: false, default: false
    add_column :events, :paper_application_required, :boolean, null: false, default: false
  end
end
