class Event::Camp < Event

  # This statement is required because this class would not be loaded otherwise.
  require_dependency 'event/camp/role/helper'
  require_dependency 'event/camp/role/participant'

  include Event::RestrictedRole

  self.used_attributes += [:state, :group_ids, :abteilungsleitung_id, :coach_id, :advisor_mountain_security_id,
                           :advisor_snow_security_id, :advisor_water_security_id]

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
