#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddContactAttrsPassedOnToSupercampToEvents < ActiveRecord::Migration
  def up
    add_column :events, :contact_attrs_passed_on_to_supercamp, :text, limit: 65535

    Event.reset_column_information
    Event::Course.reset_column_information
    Event::Camp.reset_column_information
  end

  def down
    remove_column :events, :contact_attrs_passed_on_to_supercamp
  end
end
