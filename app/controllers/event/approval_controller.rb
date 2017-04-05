# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::ApprovalController < CrudController

  def self.model_class
    Event::Approval
  end

  private

  def entry
    application.approvals.build
  end

  def application
    @application ||= participation.application
  end

  def event
    @event ||= group.events.find(params[:event_id].to_i)
  end

  def participation
    @participation ||= event.participations.find(params[:participation_id].to_i)
  end

  def group
    @group ||= Group.find(params[:group_id].to_i)
  end

end
