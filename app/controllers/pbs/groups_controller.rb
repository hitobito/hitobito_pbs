# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::GroupsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :permitted_attrs, :pbs_fields
    before_render_show :set_crisis_flash
  end

  def pending_approvals
    @approvals = Event::Approval.pending(entry).
                 includes(:participation, :approvee, event: [:dates, :groups]).
                 order('event_participations.created_at ASC')
  end

  private

  def permitted_attrs_with_pbs_fields
    attrs = permitted_attrs_without_pbs_fields
    attrs << { cantons: [] } if entry.class.used_attributes.include?(:cantons)
    if entry.class.used_attributes.include?(:geolocations)
      attrs << { geolocations_attributes: [:id, :lat, :long, :_destroy] }
    end
    attrs
  end

  def set_crisis_flash
    if entry.active_crisis
      flash.now[:alert] = I18n.t('groups.ongoing_crisis',
                                 creator: entry.active_crisis.creator.full_name)
    end
  end

end
