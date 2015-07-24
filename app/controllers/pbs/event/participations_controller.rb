# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationsController
  extend ActiveSupport::Concern

  included do
    before_render_show :load_approvals
    before_render_form :inform_about_email_sent_to_participant

    alias_method_chain :send_confirmation_email, :current_user
    alias_method_chain :build_application, :state

    skip_load_and_authorize_resource only: [:new_tentative]
  end

  def cancel
    entry.canceled_at = params[:event_participation][:canceled_at]
    entry.state = 'canceled'
    if entry.save
      Event::CanceledParticipationJob.new(entry).enqueue!
      flash[:notice] = t('event.participations.canceled_notice', participant: entry.person)
    else
      flash[:alert] = entry.errors.full_messages
    end
    redirect_to group_event_participation_path(group, event, entry)
  end

  def reject
    entry.state = 'rejected'
    if entry.save
      flash[:notice] = t('event.participations.rejected_notice', participant: entry.person, mailto: mailto_link)
    else
      flash[:alert] = entry.errors.full_messages
    end
    redirect_to group_event_participation_path(group, event, entry)
  end

  private

  def load_approvals
    @approvals = Event::Approval.where(application_id: entry.application_id).includes(:approver)
  end

  def send_confirmation_email_with_current_user
    Event::ParticipationConfirmationJob.new(entry, current_user).enqueue!
  end

  def inform_about_email_sent_to_participant
    if new_record_for_someone_else?(entry) && !event.tentative_applications?
      flash.now[:notice] = t('event.participations.inform_about_email_sent_to_participant')
    end
  end

  def build_application_with_state(participation)
    build_application_without_state(participation)
    participation.state = new_record_for_someone_else?(participation) ? 'assigned' : 'applied'
  end

  def new_record_for_someone_else?(participation)
    participation.new_record? && participation.person != current_user
  end

  def mailto_link
    if email = entry.person.email
      cc = (entry.event.organizers + entry.approvers).collect(&:email).compact.join(',')
      view_context.mail_to(email.html_safe,
                           t('event.participations.rejected_email_link'),
                           cc: cc.html_safe)
    end
  end

end
