# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::Camp < Event

  # This statement is required because this class would not be loaded otherwise.
  require_dependency 'event/camp/role/helper'
  require_dependency 'event/camp/role/participant'

  include Event::RestrictedRole

  # rubocop:disable LineLength
  self.used_attributes += [:state, :group_ids, :abteilungsleitung_id, :coach_id, :advisor_mountain_security_id,
                           :advisor_snow_security_id, :advisor_water_security_id,
                           :expected_participants_wolf_f, :expected_participants_wolf_m,
                           :expected_participants_pfadi_f, :expected_participants_pfadi_m,
                           :expected_participants_pio_f, :expected_participants_pio_m,
                           :expected_participants_rover_f, :expected_participants_rover_m,
                           :expected_participants_leitung_f, :expected_participants_leitung_m,
                           :camp_days,
                           :camp_location, :camp_location_address, :camp_location_coordinates,
                           :camp_location_altitude, :camp_location_emergency_phone,
                           :camp_location_owner, :camp_location_approved,
                           :j_s_kind,
                           :j_s_security_snow, :j_s_security_mountain, :j_s_security_water,
                           :participants_can_apply, :participants_can_cancel,
                           :al_present, :al_visiting, :al_visiting_date,
                           :coach_visiting, :coach_visiting_date, :coach_confirmed,
                           :local_scout_contact_present, :local_scout_contact,
                           :camp_submitted
                          ]

  self.role_types = [Event::Camp::Role::Leader,
                     Event::Camp::Role::AssistantLeader,
                     Event::Camp::Role::Helper,
                     Event::Camp::Role::LeaderMountainSecurity,
                     Event::Camp::Role::LeaderSnowSecurity,
                     Event::Camp::Role::LeaderWaterSecurity,
                     Event::Camp::Role::Participant]

  restricted_role :abteilungsleitung, Event::Camp::Role::Abteilungsleitung
  restricted_role :coach, Event::Camp::Role::Coach
  restricted_role :advisor_mountain_security, Event::Camp::Role::AdvisorMountainSecurity
  restricted_role :advisor_snow_security, Event::Camp::Role::AdvisorSnowSecurity
  restricted_role :advisor_water_security, Event::Camp::Role::AdvisorWaterSecurity

end
