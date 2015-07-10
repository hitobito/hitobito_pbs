# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventsController
  extend ActiveSupport::Concern

  def list_completed_approvals
    # TODO ama: why do I have to authorize here and call is unncessary in groups controller?
    authorize!(:list_completed_approvals, entry)

    @approvals = Event::Approval.completed(entry).
      includes(:approvee, :approver, :participation, :application).
      order('people.id')
  end

end
