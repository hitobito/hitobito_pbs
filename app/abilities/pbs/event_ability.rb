# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventAbility
  extend ActiveSupport::Concern

  include Pbs::EventConstraints

  included do
    on(Event) do
      general(:update, :destroy, :application_market, :qualify).
        at_least_one_group_not_deleted_and_not_closed_or_admin


      permission(:any).may(:update).for_managed_events

      permission(:any).may(:index_participations_details).for_leaded_events
      permission(:group_full).may(:index_participations_details).in_same_group
      permission(:layer_and_below_full).may(:index_participations_details).in_same_layer_or_below

      permission(:any).may(:list_completed_approvals).for_leaded_events
      permission(:layer_and_below_full).may(:list_completed_approvals).in_same_layer_or_below
    end
  end

  def for_managed_events
    permission_in_event?(:event_full) && permission_in_event?(:qualify)
  end

end
