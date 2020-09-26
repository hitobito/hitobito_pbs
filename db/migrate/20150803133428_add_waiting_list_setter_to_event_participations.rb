# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddWaitingListSetterToEventParticipations < ActiveRecord::Migration[4.2]

  def change
    add_column(:event_participations, :waiting_list_setter_id, :integer)
  end

end
