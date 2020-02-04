#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddSubcampFieldToQuestions < ActiveRecord::Migration
  def up
    add_column :event_questions, :pass_on_to_supercamp, :boolean, null: false, default: false
  end

  def down
    remove_column :event_questions, :pass_on_to_supercamp
  end
end
