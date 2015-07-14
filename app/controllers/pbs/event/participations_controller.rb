# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationsController
  extend ActiveSupport::Concern

  included do
    before_render_show :load_approvals
    before_render_show :populate_errors
  end

  private

  def load_approvals
    @approvals = Event::Approval.where(application_id: entry.application_id).includes(:approver)
  end

  def populate_errors
    checker = Event::PreconditionChecker.new(entry.event, entry.person)
    @errors = checker.errors_text unless checker.valid?
  end

end
