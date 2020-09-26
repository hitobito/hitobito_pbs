# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::RolesController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :after_create_location, :deleted
    alias_method_chain :after_update_location, :deleted
    alias_method_chain :model_scope, :deleted
  end

  private

  def model_scope_with_deleted
    model_scope_without_deleted.with_deleted
  end

  def after_create_location_with_deleted(new_person)
    return_path ||
      if model_params[:deleted_at].present?
        group_people_path(entry.group_id)
      else
        after_create_location_without_deleted(new_person)
      end
  end

  def after_update_location_with_deleted
    if model_params[:deleted_at]
      group_people_path(entry.group_id)
    else
      after_update_location_without_deleted
    end
  end

end
