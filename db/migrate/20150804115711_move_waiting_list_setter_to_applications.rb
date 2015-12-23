# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class MoveWaitingListSetterToApplications < ActiveRecord::Migration
  def up
    remove_column(:event_participations, :waiting_list_setter_id)
    add_column(:event_applications, :waiting_list_setter_id, :integer)

    Event::Participation.reset_column_information
    Event::Application.reset_column_information
  end

  def down
    remove_column(:event_applications, :waiting_list_setter_id)
    add_column(:event_participations, :waiting_list_setter_id, :integer)
  end
end
