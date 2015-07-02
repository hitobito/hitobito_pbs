# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CreateEventApprovals < ActiveRecord::Migration
  def change
    create_table :event_approvals do |t|
      t.integer :application_id, null: false
      t.string :layer, null: false
      t.boolean :approved, null: false, default: false
      t.boolean :rejected, null: false, default: false
      t.text :comment
      t.datetime :approved_at
      t.integer :person_id
    end

    add_index :event_approvals, :application_id

    add_column :events, :requires_approval_abteilung, :boolean, null: false, default: false
    add_column :events, :requires_approval_region, :boolean, null: false, default: false
    add_column :events, :requires_approval_kantonalverband, :boolean, null: false, default: false
    add_column :events, :requires_approval_bund, :boolean, null: false, default: false
  end
end
