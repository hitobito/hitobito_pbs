#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::EventSerializer
  extend ActiveSupport::Concern

  included do # rubocop:todo Metrics/BlockLength
    extension(:public) do |_| # rubocop:todo Metrics/BlockLength
      used_attributes = item.used_attributes(:applicant_count,
        :expected_participants_wolf_f,
        :expected_participants_wolf_m,
        :expected_participants_pfadi_f,
        :expected_participants_pfadi_m,
        :expected_participants_pio_f,
        :expected_participants_pio_m,
        :expected_participants_rover_f,
        :expected_participants_rover_m,
        :expected_participants_leitung_f,
        :expected_participants_leitung_m,
        :canton,
        :coordinates,
        :altitude,
        :emergency_phone,
        :j_s_kind,
        :j_s_security_snow,
        :j_s_security_mountain,
        :j_s_security_water,
        :required_contact_attrs,
        :hidden_contact_attrs)
      map_properties(*used_attributes)

      if item.used_attributes(:abteilungsleitung_id).any?
        entity :abteilungsleitung, item.abteilungsleitung, ContactSerializer
      end

      if item.used_attributes(:leader_id).any?
        entity :leader, item.leader, ContactSerializer
      end

      if item.used_attributes(:coach_id).present?
        entity :coach, item.coach, ContactSerializer
      end

      if item.allow_sub_camps?
        entities :sub_camps, item.sub_camps, Pbs::EventLinkSerializer
      end

      if item.is_a?(Event::Camp) && item.super_camp
        entity :super_camp, item.super_camp, Pbs::EventLinkSerializer
      end
    end
  end
end
