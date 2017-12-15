# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::AttendancesController < ApplicationController

  before_action :authorize

  decorates :group, :event, :leaders, :participants, :cooks

  helper_method :event

  def index
    load_entries
  end

  def update
    bsv_days = params[:bsv_days]
    if bsv_days
      event.participations.each do |p|
        next unless bsv_days.key?(p.id.to_s)
        p.update(bsv_days: bsv_days[p.id.to_s])
      end
    end
    redirect_to attendances_group_event_path(group, event),
                notice: I18n.t('event/attendances.update.flash.success')
  end


  private

  def load_entries
    types = event.role_types
    @leaders = participations(*types.select(&:leader?), Event::Role::Speaker)
    @participants = participations(Event::Course::Role::Participant)
    @cooks = participations(Event::Role::Cook)
  end

  def event
    @event ||= group.events.find(params[:id])
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def participations(*role_types)
    event.participations_for(*role_types).includes(:roles)
  end

  def authorize
    not_found unless event.course_kind?
    authorize!(:manage_attendances, event)
  end

end
