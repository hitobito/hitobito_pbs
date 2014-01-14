# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CreateCensus < ActiveRecord::Migration
  def change
    create_table :censuses do |t|
      t.integer :year, null: false
      t.date    :start_at
      t.date    :finish_at
    end

    add_index :censuses, :year, unique: true

    create_table :member_counts do |t|
      t.integer :kantonalverband_id, null: false
      t.integer :region_id
      t.integer :abteilung_id, null: false
      t.integer :year, null: false
      t.integer :leiter_f
      t.integer :leiter_m
      t.integer :biber_f
      t.integer :biber_m
      t.integer :woelfe_f
      t.integer :woelfe_m
      t.integer :pfadis_f
      t.integer :pfadis_m
      t.integer :pios_f
      t.integer :pios_m
      t.integer :rover_f
      t.integer :rover_m
      t.integer :pta_f
      t.integer :pta_m
    end

    add_index :member_counts, [:kantonalverband_id, :year]
    add_index :member_counts, [:region_id, :year]
    add_index :member_counts, [:abteilung_id, :year]
  end
end
