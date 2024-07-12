#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Filter
  extend ActiveSupport::Concern

  included do
    alias_method_chain :relevant_group_ids, :canton
    alias_method_chain :scope, :canton
  end

  private

  def scope_with_canton
    return scope_without_canton unless filter == "canton"

    scope_without_canton.where(canton: cantons)
  end

  def relevant_group_ids_with_canton
    return relevant_group_ids_without_canton unless filter == "canton"

    Group.pluck(:id)
  end

  def kantonalverbaende
    Group::Kantonalverband
      .where(id: KantonalverbandCanton.where(canton: cantons).select("kantonalverband_id"))
  end

  def cantons
    if group.respond_to?(:kantonalverband)
      group.kantonalverband.cantons
    end.to_a
  end
end
