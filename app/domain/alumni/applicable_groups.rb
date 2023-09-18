# encoding: utf-8

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

    def silverscout_groups
      Group::Silverscouts::Region #.where.not(self_registration_role_type: nil)
    end

    def alumni_groups
      find_alumni_groups(role.group.layer_group)
    end

    private

    def find_alumni_groups(layer)
      return [] if layer.root? || layer.is_a?(Group::Bund)

      find_alumni_groups(layer.parent) +
        Group::Ehemalige.where(layer_group_id: layer.id).to_a
    end
  end
end
