# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddParticipationState < ActiveRecord::Migration
  def change
    add_column(:event_participations, :state, :string, limit: 60)

    reversible do |dir|
      dir.up do
        course_participations = Event::Participation.joins(:event).
          where(events: { type: Event::Course.sti_name })
        course_participations.where(active: true).update_all(state: :assigned)
        course_participations.where(active: false).update_all(state: :applied)
      end
    end
  end
end
