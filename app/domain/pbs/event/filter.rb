# encoding: utf-8

#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Filter
  extend ActiveSupport::Concern

  included do
    alias_method_chain :list_entries, :canton
  end

  def list_entries_with_canton
    if filter == 'canton'
      scope = Event.
        where(type: type, canton: cantons).
        includes(:groups).
        in_year(year).order_by_date.preload_all_dates.uniq

      sort_expression ? scope.reorder(sort_expression) : scope
    else
      list_entries_without_canton
    end
  end

  private

  def cantons
    if group.respond_to?(:kantonalverband)
      group.kantonalverband.cantons
    end.to_a
  end
end
