#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CreateCrises < ActiveRecord::Migration[4.2]
  def change
    create_table :crises do |t|
      t.integer :creator_id, null: false
      t.integer :group_id, null: false
      t.boolean :acknowledged, null: false, default: false
      t.boolean :completed, null: false, default: false

      t.timestamps null: false

      t.index :creator_id
      t.index :group_id
    end
  end
end
