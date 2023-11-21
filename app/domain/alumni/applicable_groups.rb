# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Alumni
  class ApplicableGroups
    attr_reader :role

    def initialize(role)
      @role = role
    end

    def silverscout_group_ids
      Group::SilverscoutsRegion.
        without_deleted.
        where.not(self_registration_role_type: nil).
        pluck(:id)
    end

    def ex_members_group_ids
      ancestor_layers = role.group.layer_group.self_and_ancestors
      Group::Ehemalige.
        without_deleted.
        where(layer_group_id: ancestor_layers).
        where.not(self_registration_role_type: nil).
        pluck(:id)
    end
  end
end
