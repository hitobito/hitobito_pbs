# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PeopleController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :prepare_tabular_entries, :layer_group
  end

  private

  def prepare_tabular_entries_with_layer_group(entries, full)
    entries = prepare_tabular_entries_without_layer_group(entries, full)
    entries.includes(:primary_group)
  end

end
