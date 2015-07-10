# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Sheet::Event::Participation
  extend ActiveSupport::Concern

  included do
    tab 'global.tabs.info',
        :group_event_participation_path,
        no_alt: true

    tab 'event.participations.tabs.approvals',
        :completed_approvals_group_event_participation_path,
        if: :completed_approvals
  end

end
