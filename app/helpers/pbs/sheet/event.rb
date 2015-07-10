# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Sheet::Event
  extend ActiveSupport::Concern

  included do
    tabs.push(Sheet::Tab.new('events.tabs.approvals',
                             :approvals_group_event_path,
                             if: lambda { |view, group, event|
                               view.can?(:list_completed_approvals, event)
                             }))
  end

end
