# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Participation) do
      permission(:any).may(:cancel_own).her_own_if_participant_can_cancel

      permission(:layer_and_below_full).
        may(:create, :destroy).
        in_same_layer_or_course_in_below_abteilung
    end
  end

  def her_own_if_participant_can_cancel
    participation.person == user &&
    event.respond_to?(:cancel_possible?) &&
    event.cancel_possible? &&
    participation.active?
  end
end
