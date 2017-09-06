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

    after_action :send_discarded_info, only: [:cancel, :reject]
    after_reject :notice_with_mailto

    alias_method_chain :send_confirmation_email, :current_user
    alias_method_chain :permitted_attrs, :state
  end

  def cancel_own
    entry.update!(state: 'canceled')
    Event::CanceledCampParticipationJob.new(entry).enqueue!
    redirect_to group_event_path(group, event),
                notice: t('event.participations.canceled_own_notice')
  end

  private

  def load_approvals
    @approvals = Event::Approval.
      where(application_id: entry.application_id).
      includes(:approver).
      order_by_layer
  end

  def send_confirmation_email_with_current_user
    Event::ParticipationConfirmationJob.new(entry, current_user).enqueue!
  end

  def send_discarded_info
    Event::DiscardedCourseParticipationJob.new(entry, entry.previous_changes[:state].first).enqueue!
  end

  def inform_about_email_sent_to_participant
    if new_record_for_someone_else? && !event.tentative_applications?
      flash.now[:notice] = t('event.participations.inform_about_email_sent_to_participant')
    end
  end

  def notice_with_mailto
    flash[:notice] = t('event.participations.rejected_notice',
                       participant: entry.person,
                       mailto: rejected_mailto_link)
  end

  def rejected_mailto_link
    to = Person.mailing_emails_for([entry.person])
    if to.present?
      cc = Person.mailing_emails_for(entry.event.organizers + entry.approvers)
      view_context.mail_to(to.join(','),
                           t('event.participations.rejected_email_link'),
                           cc: cc.join(','))
    end
  end

  def permitted_attrs_with_state
    attrs = permitted_attrs_without_state.dup
    attrs << :state if event.is_a?(Event::Camp)
    attrs
  end

end
