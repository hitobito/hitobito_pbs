#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class RemovePbsNumberFromPeople < ActiveRecord::Migration[8.0]
  def up
    remove_column :people, :search_column, if_exists: true
    remove_column :people, :pbs_number, if_exists: true
  end

  def down
    remove_column :people, :search_column, if_exists: true
    add_column :people, :pbs_number, :string
  end
end
