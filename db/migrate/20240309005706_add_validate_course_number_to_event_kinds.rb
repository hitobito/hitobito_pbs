#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class AddValidateCourseNumberToEventKinds < ActiveRecord::Migration[6.1]
  def change
    add_column :event_kinds, :validate_course_number, :boolean, default: false, null: false
    
    Event::Kind.reset_column_information
  end
end
