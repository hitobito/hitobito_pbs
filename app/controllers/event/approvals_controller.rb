# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::ApprovalsController < CrudController

  self.nesting = Group, Event, Event::Participation

  self.permitted_attrs = [:current_occupation, :current_level, :occupation_assessment,
                          :strong_points, :weak_points, :comment]

  decorates :group, :event, :participation

  def create
    if approver.send(decision, permitted_params, current_user)
      flash[:notice] = send("notice_#{decision}")
      redirect_to group_event_participation_path(@group, participation.event_id, participation)
    else
      @approval = approver.open_approval
      render 'new'
    end
  end

  private

  def self.model_class
    Event::Approval
  end

  def decision
    @decision ||= params[:decision].to_s.tap do |decision|
      unless %w(approve reject).include?(decision)
        raise ArgumentError, "Invalid decision #{decision}"
      end
    end
  end

  def approver
    @approver ||= Event::Approver.new(participation)
  end

  def notice_approve
    I18n.t('event/applications.approved')
  end

  def notice_reject
    [I18n.t('event/applications.rejected'),
     translate(:rejected_inform_participant, participant: participation.person)]
  end

  def list_entries
    event.approvals
  end

  def build_entry
    application.next_open_approval
  end

  def application
    participation.application
  end

  def participation
    parent
  end

  def parent_entry(clazz)
    id = params["#{clazz.name.demodulize.underscore}_id"]
    model_ivar_set(clazz.find(id))
  end

end
