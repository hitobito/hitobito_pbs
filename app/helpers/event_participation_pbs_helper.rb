# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module EventParticipationPbsHelper

  def show_event_participation_cancel_button?
    if can?(:cancel, entry)
      if !entry.canceled? && !entry.rejected?
        return true
      end
    end
  end

  def show_event_participation_reject_button?
    if can?(:reject, entry)
      if entry.assigned? || entry.applied?
        return true
      end
    end
  end

end
