# frozen_string_literal: true

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PersonReadables
  extend ActiveSupport::Concern

  def append_group_conditions(condition)
    user.crises.active.each do |crisis|
      group = crisis.group.layer_group
      condition.or('groups.lft >= ? AND groups.rgt <= ?', group.lft, group.rgt)
    end
    super
  end

  def has_group_based_conditions?
    user.crises.active.any? || super
  end

end
