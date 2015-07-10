# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::GroupsController
  extend ActiveSupport::Concern

  def list_pending_approvals
    @approvals = Event::Approval.pending(entry).includes(:approvee, :event).order('events.id')
  end

end
