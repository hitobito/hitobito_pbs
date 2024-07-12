# frozen_string_literal: true

#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Events::Filter::Groups
  extend ActiveSupport::Concern

  included do
    def to_scope
      scope = @scope
      scope = scope.in_hierarchy(@user) unless complete_course_list_allowed?
      group_ids.any? ? scope.with_group_id(group_ids) : scope
    end
  end
end
