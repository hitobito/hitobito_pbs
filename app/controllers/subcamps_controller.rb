#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class SubcampsController < ListController
  helper_method :group, :event

  def self.model_class
    Event
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
  end

  def event
    @event ||= group.events.find(params[:event_id])
  end

  def authorize_class
    authorize!(:index_events, Group)
  end
end
