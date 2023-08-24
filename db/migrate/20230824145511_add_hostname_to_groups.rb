#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddHostnameToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :hostname, :string

    add_index :groups, :hostname, unique: true
  end
end
