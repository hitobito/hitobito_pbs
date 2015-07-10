# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationAbility
  extend ActiveSupport::Concern

  include Pbs::EventConstraints

  included do
    on(Event::Participation) do
      general(:update, :destroy).not_closed_or_admin
      general(:create).at_least_one_group_not_deleted_and_not_closed_or_admin

      permission(:any).may(:completed_approvals).for_participations_full_events
      permission(:group_full).may(:completed_approvals).in_same_group
      permission(:layer_full).may(:completed_approvals).in_same_layer
      permission(:layer_and_below_full).may(:completed_approvals).in_same_layer_or_below_or_different_prio

      general(:completed_approvals).supports_applications_and_not_her_own?
    end
  end

  def supports_applications_and_not_her_own?
    subject.event.supports_applications? && subject.application.present? && !her_own
  end

end
