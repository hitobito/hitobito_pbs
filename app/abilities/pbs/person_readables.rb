# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PersonReadables
  extend ActiveSupport::Concern

  included do
    alias_method_chain :append_group_conditions, :crisis
  end

  def append_group_conditions_with_crisis(condition)
    user.crises.active.each do |crisis|
      group = crisis.group.layer_group
      condition.or('groups.lft >= ? AND groups.rgt <= ?', group.lft, group.rgt)
    end
    append_group_conditions_without_crisis(condition)
  end

end
