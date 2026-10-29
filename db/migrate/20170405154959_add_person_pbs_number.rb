#  Copyright (c) 2017-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddPersonPbsNumber < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :pbs_number, :string
  end
end
