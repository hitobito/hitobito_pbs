module Event::Campy

  extend ActiveSupport::Concern

  ABROAD_CANTON = 'zz'

  J_S_KINDS = %w(j_s_child j_s_youth j_s_mixed)

  CANTONS = Cantons.short_name_strings + [ABROAD_CANTON]

  EXPECTED_PARTICIPANT_ATTRS = [:expected_participants_wolf_f, :expected_participants_wolf_m,
                                :expected_participants_pfadi_f, :expected_participants_pfadi_m,
                                :expected_participants_pio_f, :expected_participants_pio_m,
                                :expected_participants_rover_f, :expected_participants_rover_m,
                                :expected_participants_leitung_f, :expected_participants_leitung_m]

  LEADER_CHECKPOINT_ATTRS = [:lagerreglement_applied,
                             :kantonalverband_rules_applied,
                             :j_s_rules_applied]

  def self.extended(base)
    base.class_eval(&@_included_block)
  end

  included do
    self.used_attributes += [:leader_id, :abteilungsleitung_id, :coach_id,
                             :advisor_mountain_security_id, :advisor_snow_security_id,
                             :advisor_water_security_id,
                             :canton, :coordinates, :altitude, :emergency_phone,
                             :landlord, :landlord_permission_obtained,
                             :j_s_kind,
                             :j_s_security_snow, :j_s_security_mountain, :j_s_security_water,
                             :paper_application_required,
                             :al_present, :al_visiting, :al_visiting_date,
                             :coach_visiting, :coach_visiting_date, :coach_confirmed,
                             :local_scout_contact_present, :local_scout_contact,
                             :camp_submitted]

    self.used_attributes += EXPECTED_PARTICIPANT_ATTRS
    self.used_attributes += LEADER_CHECKPOINT_ATTRS

    self.role_types += [Event::Camp::Role::LeaderMountainSecurity,
                        Event::Camp::Role::LeaderSnowSecurity,
                        Event::Camp::Role::LeaderWaterSecurity]

    restricted_role :leader, Event::Camp::Role::Leader
    restricted_role :abteilungsleitung, Event::Camp::Role::Abteilungsleitung
    restricted_role :coach, Event::Camp::Role::Coach
    restricted_role :advisor_mountain_security, Event::Camp::Role::AdvisorMountainSecurity
    restricted_role :advisor_snow_security, Event::Camp::Role::AdvisorSnowSecurity
    restricted_role :advisor_water_security, Event::Camp::Role::AdvisorWaterSecurity

    ### VALIDATIONS

    validates *EXPECTED_PARTICIPANT_ATTRS,
              numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_blank: true }
    validates :j_s_kind, inclusion: { in: J_S_KINDS, allow_blank: true }
    validates :canton, inclusion: { in: CANTONS, allow_blank: true }

    with_options if: :camp_submitted?, presence: true do
      validates :canton, :location, :altitude, :emergency_phone,
                :landlord, :coach_id, :coach_confirmed,
                :leader_id, :lagerreglement_applied, :kantonalverband_rules_applied,
                :j_s_rules_applied, :coordinates,
                # check if any of the expected attrs has an assigned value
                :any_expected_participant_attr
    end

    with_options presence: true do
      # only check these attrs if security required for given topic
      validates :advisor_snow_security_id, if: -> { camp_submitted? && j_s_security_snow }
      validates :advisor_mountain_security_id, if: -> { camp_submitted? && j_s_security_mountain }
      validates :advisor_water_security_id, if: -> { camp_submitted? && j_s_security_water }
    end

    ### CALLBACKS

    after_save :reset_checkpoint_attrs_if_leader_changed
    after_save :reset_coach_confirmed_if_changed

  end

  def abroad?
    canton == ABROAD_CANTON
  end

  def camp_days
    dates.to_a.sum do |d|
      event_date_day_count(d)
    end
  end

  private

  def reset_coach_confirmed_if_changed
    if coach_confirmed? && restricted_role_changes[:coach]
      update_column(:coach_confirmed, false)
    end
    true
  end

  def reset_checkpoint_attrs_if_leader_changed
    if restricted_role_changes[:leader]
      LEADER_CHECKPOINT_ATTRS.each do |a|
        update_column(a, false)
      end
    end
  end

  def event_date_day_count(date)
    return 1 unless date.finish_at
    start_at = date.start_at.to_date
    finish_at = date.finish_at.to_date
    (finish_at - start_at).to_i + 1
  end

  def any_expected_participant_attr
    EXPECTED_PARTICIPANT_ATTRS.find do |a|
      send(a).present?
    end
  end

end
