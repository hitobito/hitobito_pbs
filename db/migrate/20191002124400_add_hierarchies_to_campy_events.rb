#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddHierarchiesToCampyEvents < ActiveRecord::Migration
  def change
    add_column :events, :parent_id, :integer, null: true
    add_column :events, :allow_sub_camps, :boolean, null: false, default: false
  end
end

