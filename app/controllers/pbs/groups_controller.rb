# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::GroupsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :permitted_attrs, :cantons
  end

  def pending_approvals
    authorize!(:pending_approvals, entry)

    @approvals = Event::Approval.pending(entry).
      includes(:participation, :approvee, event: [:dates, :groups]).
      order('event_participations.created_at ASC')
  end

  private

  def permitted_attrs_with_cantons
    attrs = permitted_attrs_without_cantons
    attrs << { cantons: [] } if entry.class.used_attributes.include?(:cantons)
    attrs
  end

end
