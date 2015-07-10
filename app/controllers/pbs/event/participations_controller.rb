# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationsController
  extend ActiveSupport::Concern

  def completed_approvals
    authorize!(:completed_approvals, entry)
    @approvals = load_approvals
  end

  private

  def load_approvals
    Event::Approval.where(application_id: entry.application_id).includes(:approver)
  end

end
