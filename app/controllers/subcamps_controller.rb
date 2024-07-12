#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class SubcampsController < ListController
  self.nesting = Group

  helper_method :event

  decorates :group, :event, :events

  def self.model_class
    Event
  end

  private

  def event
    @event ||= parent.events.find(params[:event_id])
  end

  def list_entries
    case params[:filter]
    when "direct" then event.sub_camps
    else event.descendants # handles 'all' also
    end.includes(:groups)
  end

  def authorize_class
    authorize!(:index_events, Group)
  end
end
