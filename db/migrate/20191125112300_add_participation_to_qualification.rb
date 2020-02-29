#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddParticipationToQualification < ActiveRecord::Migration
  def up
    add_reference :qualifications, :event_participation, foreign_key: { on_delete: :nullify }
    Qualification.reset_column_information
  end

  def down
    remove_reference :qualifications, :event_participation
  end
end
