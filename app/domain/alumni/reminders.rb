# encoding: utf-8

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module People
  class AlumniReminders < AlumniInvitations
    self.time_range = ..6.months.ago
    self.type = :reminder
  end
end
