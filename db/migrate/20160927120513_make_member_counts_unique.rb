# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class MakeMemberCountsUnique < ActiveRecord::Migration[4.2]
  def change
    remove_index :member_counts, [:abteilung_id, :year]
    add_index :member_counts,
              [:abteilung_id, :year],
              unique: true,
              name: 'index_member_counts_unique_per_year'
  end
end
