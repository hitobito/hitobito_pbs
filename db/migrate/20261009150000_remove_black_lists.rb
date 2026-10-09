#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class RemoveBlackLists < ActiveRecord::Migration[7.1]
  def up
    CustomContent.where(key: %w[black_list_hit black_list_attr_hit]).destroy_all

    drop_table :black_lists
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
