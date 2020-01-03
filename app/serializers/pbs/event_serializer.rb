# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::EventSerializer
  extend ActiveSupport::Concern

  included do
    extension(:public) do |_|
      map_properties(*item.used_attributes(:applicant_count,
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
                                           :hidden_contact_attrs))
    end
  end
end

