# frozen_string_literal: true

#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class SetAutomaticAssignmentForPbsCourses < ActiveRecord::Migration[6.1]
  def up
    Event::Course.update_all(automatic_assignment: false)
  end
end
