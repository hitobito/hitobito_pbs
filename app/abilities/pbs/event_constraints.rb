# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventConstraints

  def not_closed_or_admin
    user_context.admin || !closed_course?
  end

  def at_least_one_group_not_deleted_and_not_closed_or_admin
    at_least_one_group_not_deleted && not_closed_or_admin
  end

  def for_managed_events
    permission_in_event?(:event_full) && permission_in_event?(:qualify)
  end

  private

  def closed_course?
    event.is_a?(Event::Course) && event.closed?
  end

end
