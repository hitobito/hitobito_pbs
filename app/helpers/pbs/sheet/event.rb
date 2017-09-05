# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Sheet::Event
  extend ActiveSupport::Concern

  included do
    tabs.insert(
      -1,
      Sheet::Tab.new('events.tabs.approvals',
                     :group_event_approvals_path,
                     if: (lambda do |view, _group, event|
                       event.course_kind? && view.can?(:index_approvals, event)
                     end)),
      Sheet::Tab.new('events.tabs.attendances',
                     :attendances_group_event_path,
                     if: (lambda do |view, _group, event|
                       event.course_kind? && view.can?(:manage_attendances, event)
                     end))
    )
  end

end
