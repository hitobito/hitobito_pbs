# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::ApprovalsController < CrudController

  self.permitted_attrs = [:current_occupation, :current_level, :occupation_assessment,
                          :strong_points, :weak_points, :comment]

  decorates :group, :event, :participation

  def new
    redirect_to participation_path unless entry
  end

  def index
    @approvals = entries.group_by(&:participation)
  end

  def create
    if approver.send(decision, permitted_params, current_user)
      flash[:notice] = send("notice_#{decision}")
      redirect_to participation_path
    else
      @approval = approver.open_approval
      render 'new'
    end
  end

  def self.model_class
    Event::Approval
  end

  private

  def participation_path
    group_event_participation_path(@group, participation.event_id, participation)
  end

  # Override to handle possible nil return from build_entry
  def model_ivar_set(entry)
    @approval = entry
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

  def build_entry
    participation.application.next_open_approval
  end

  def list_entries
    Event::Approval.
      joins(participation: :person).
      where(event_participations: { event_id: event.id, active: true }).
      includes(approver: [:phone_numbers, :roles, :groups],
               participation: [:event, :application, person: :primary_group]).
      merge(Person.order_by_name).
      order_by_layer
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def event
    @event ||= group.events.find(params[:event_id])
  end

  def model_scope
    participation.application.approvals
  end

  def participation
    @participation ||= event.participations.find(params[:participation_id])
  end

  def authorize_class
    authorize!(:index_approvals, event)
  end

  def full_entry_label
    models_label(false)
  end

  def return_path
    group_event_participation_path(@group, @event, @participation)
  end

end
