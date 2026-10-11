# frozen_string_literal: true

#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Example usage: rake qualis:merge_js_leiter_lst[41,39,40,true]
namespace :qualis do
  desc "Merges the still valid J+S Leiter*in LS/T Kinder and Jugendliche qualifications " \
       "into the new J+S Leiter*in LS/T qualification (pbs#482)"
  task :merge_js_leiter_lst, [:target_kind_id, :kinder_kind_id, :jugendliche_kind_id, :dry_run] =>
    :environment do |_task, args|
    require_relative "qualis/merge_js_leiter_lst"
    Qualis::MergeJsLeiterLst.new(target_kind_id: args[:target_kind_id],
      source_kind_ids: [args[:kinder_kind_id], args[:jugendliche_kind_id]],
      dry_run: ActiveModel::Type::Boolean.new.cast(args[:dry_run]) || false).run
  end
end
