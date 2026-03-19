#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Events::Filter::GroupList
  private

  def filtered_scope_with_selection
    return super unless range == "canton"

    super.where(canton: cantons)
  end

  def relevant_group_ids
    return super unless range == "canton"

    Group.select(:id)
  end

  def cantons
    if group.respond_to?(:kantonalverband)
      group.kantonalverband.cantons
    end.to_a
  end
end
