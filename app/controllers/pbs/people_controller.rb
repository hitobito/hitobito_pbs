# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PeopleController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :prepare_tabular_entries, :layer_group
    alias_method_chain :render_tabular_in_background, :detail
  end

  private

  def prepare_tabular_entries_with_layer_group(entries, full)
    entries = prepare_tabular_entries_without_layer_group(entries, full)
    entries.includes(:primary_group)
  end

  def render_tabular_in_background_with_detail(format, full, filename)
    Export::PeopleExportJob.new(
      format, current_person.id, @group.id, list_filter_args,
      params.slice(:household, :selection, :household_details).merge(full: full, filename: filename)
    ).enqueue!
  end

end
