# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PersonAbility
  extend ActiveSupport::Concern

  included do
    on(Person) do
      permission(:any)
        .may(:show, :show_full, :show_details, :history,
             :index_tags, :index_notes).if_member_of_crisis_group_or_oneself_or_manager
    end

    def if_member_of_crisis_group_or_oneself_or_manager
      herself || manager || member_of_crisis_group
    end

    def member_of_crisis_group
      contains_any?(user.layer_ids_with_active_crises,
                    subject.groups.flat_map { |g| g.layer_hierarchy.collect(&:id) })
    end

    def manager
      contains_any?([user.id], person.managers.pluck(:id))
    end

  end

end
