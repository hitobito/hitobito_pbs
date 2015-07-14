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
    before_render_form :inform_about_email_sent_to_participant

    alias_method_chain :send_confirmation_email, :current_user
  end

  private

  def load_approvals
    @approvals = Event::Approval.where(application_id: entry.application_id).includes(:approver)
  end

  def populate_errors
    checker = Event::PreconditionChecker.new(entry.event, entry.person)
    @errors = checker.errors_text unless checker.valid?
  end

  def send_confirmation_email_with_current_user
    Event::ParticipationConfirmationJob.new(entry, current_user).enqueue!
  end

  def inform_about_email_sent_to_participant
    if entry.new_record? && entry.person != current_user
      flash.now[:notice] = t('.inform_about_email_sent_to_participant')
    end
  end
end
