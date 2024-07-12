# frozen_string_literal: true

#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventsHelper
  extend ActiveSupport::Concern

  included do
    def course_groups
      return Group.course_offerers if can?(:list_all, Event::Course)

      Group.course_offerers.where(id: current_user.groups_hierarchy_ids)
    end
  end
end
