# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: events
#
#  id                                :integer          not null, primary key
#  type                              :string(255)
#  name                              :string(255)      not null
#  number                            :string(255)
#  motto                             :string(255)
#  cost                              :string(255)
#  maximum_participants              :integer
#  contact_id                        :integer
#  description                       :text
#  location                          :text
#  application_opening_at            :date
#  application_closing_at            :date
#  application_conditions            :text
#  kind_id                           :integer
#  state                             :string(60)
#  priorization                      :boolean          default(FALSE), not null
#  requires_approval                 :boolean          default(FALSE), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#  participant_count                 :integer          default(0)
#  application_contact_id            :integer
#  external_applications             :boolean          default(FALSE)
#  applicant_count                   :integer          default(0)
#  teamer_count                      :integer          default(0)
#  signature                         :boolean
#  signature_confirmation            :boolean
#  signature_confirmation_text       :string(255)
#  training_days                     :decimal(12, 1)
#  language_de                       :boolean          default(FALSE), not null
#  language_fr                       :boolean          default(FALSE), not null
#  language_it                       :boolean          default(FALSE), not null
#  language_en                       :boolean          default(FALSE), not null
#  express_fee                       :string(255)
#  requires_approval_abteilung       :boolean          default(FALSE), not null
#  requires_approval_region          :boolean          default(FALSE), not null
#  requires_approval_kantonalverband :boolean          default(FALSE), not null
#  requires_approval_bund            :boolean          default(FALSE), not null
#  tentative_applications            :boolean          default(FALSE), not null
#  expected_participants_wolf_f      :integer
#  expected_participants_wolf_m      :integer
#  expected_participants_pfadi_f     :integer
#  expected_participants_pfadi_m     :integer
#  expected_participants_pio_f       :integer
#  expected_participants_pio_m       :integer
#  expected_participants_rover_f     :integer
#  expected_participants_rover_m     :integer
#  expected_participants_leitung_f   :integer
#  expected_participants_leitung_m   :integer
#  canton                            :string(2)
#  coordinates                       :string
#  altitude                          :string
#  emergency_phone                   :string
#  landlord                          :text
#  landlord_permission_obtained      :boolean          default(FALSE), not null
#  j_s_kind                          :integer
#  j_s_security_snow                 :boolean          default(FALSE), not null
#  j_s_security_mountain             :boolean          default(FALSE), not null
#  j_s_security_water                :boolean          default(FALSE), not null
#  participants_can_apply            :boolean          default(FALSE), not null
#  participants_can_cancel           :boolean          default(FALSE), not null
#  al_present                        :boolean          default(FALSE), not null
#  al_visiting                       :boolean          default(FALSE), not null
#  al_visiting_date                  :date
#  coach_visiting                    :boolean          default(FALSE), not null
#  coach_visiting_date               :date
#  coach_confirmed                   :boolean          default(FALSE), not null
#  local_scout_contact_present       :boolean          default(FALSE), not null
#  local_scout_contact               :text
#  camp_submitted                    :boolean          default(FALSE), not null
#  camp_reminder_sent                :boolean          default(FALSE), not null
#  paper_application_required        :boolean          default(FALSE), not null
#  creator_id                        :integer
#  updater_id                        :integer
#

class Event::Camp < Event

  # This statement is required because this class would not be loaded otherwise.
  require_dependency 'event/camp/role/helper'
  require_dependency 'event/camp/role/participant'

  include Event::RestrictedRole

  class_attribute :possible_j_s_kinds
  class_attribute :possible_canton_values

  EXPECTED_PARTICIPANT_ATTRS = [:expected_participants_wolf_f, :expected_participants_wolf_m,
                                :expected_participants_pfadi_f, :expected_participants_pfadi_m,
                                :expected_participants_pio_f, :expected_participants_pio_m,
                                :expected_participants_rover_f, :expected_participants_rover_m,
                                :expected_participants_leitung_f, :expected_participants_leitung_m]

  ABROAD_CANTON = 'zz'

  J_S_KINDS = %w(j_s_child j_s_youth j_s_mixed)

  CANTONS = Cantons.short_name_strings + [ABROAD_CANTON]

  LEADER_CHECKPOINT_ATTRS = [:lagerreglement_applied,
                      :kantonalverband_rules_applied,
                      :j_s_rules_applied]

  self.used_attributes += [:state, :group_ids, :leader_id,
                           :abteilungsleitung_id, :coach_id,
                           :advisor_mountain_security_id, :advisor_snow_security_id,
                           :advisor_water_security_id,
                           :expected_participants_wolf_f, :expected_participants_wolf_m,
                           :expected_participants_pfadi_f, :expected_participants_pfadi_m,
                           :expected_participants_pio_f, :expected_participants_pio_m,
                           :expected_participants_rover_f, :expected_participants_rover_m,
                           :expected_participants_leitung_f, :expected_participants_leitung_m,
                           :canton, :coordinates, :altitude, :emergency_phone,
                           :landlord, :landlord_permission_obtained,
                           :j_s_kind,
                           :j_s_security_snow, :j_s_security_mountain, :j_s_security_water,
                           :paper_application_required,
                           :participants_can_apply, :participants_can_cancel,
                           :al_present, :al_visiting, :al_visiting_date,
                           :coach_visiting, :coach_visiting_date, :coach_confirmed,
                           :local_scout_contact_present, :local_scout_contact,
                           :camp_submitted, :paper_application_required]

  self.used_attributes += LEADER_CHECKPOINT_ATTRS

  self.used_attributes -= [:contact_id]

  self.role_types = [Event::Camp::Role::AssistantLeader,
                     Event::Camp::Role::Helper,
                     Event::Camp::Role::LeaderMountainSecurity,
                     Event::Camp::Role::LeaderSnowSecurity,
                     Event::Camp::Role::LeaderWaterSecurity,
                     Event::Camp::Role::Participant]

  restricted_role :leader, Event::Camp::Role::Leader
  restricted_role :abteilungsleitung, Event::Camp::Role::Abteilungsleitung
  restricted_role :coach, Event::Camp::Role::Coach
  restricted_role :advisor_mountain_security, Event::Camp::Role::AdvisorMountainSecurity
  restricted_role :advisor_snow_security, Event::Camp::Role::AdvisorSnowSecurity
  restricted_role :advisor_water_security, Event::Camp::Role::AdvisorWaterSecurity

  # states are used for workflow
  # translations in config/locales
  self.possible_states = %w(created confirmed assignment_closed canceled closed)
  self.possible_participation_states = %w(applied_electronically assigned canceled absent)
  self.active_participation_states = %w(applied_electronically assigned)
  self.revoked_participation_states = %w(canceled absent)
  self.countable_participation_states = %w(applied_electronically assigned absent)


  ### VALIDATIONS

  validates :state, inclusion: possible_states
  validates *EXPECTED_PARTICIPANT_ATTRS,
            numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_blank: true }
  validates :j_s_kind, inclusion: { in: J_S_KINDS, allow_blank: true }
  validates :canton, inclusion: { in: CANTONS, allow_blank: true }


  ### CALLBACKS

  before_create :assign_abteilungsleitung
  after_save :send_assignment_infos
  after_save :send_abteilungsleitung_assignment_info
  after_save :send_created_infos
  after_save :reset_coach_confirmed_if_changed
  after_save :reset_checkpoint_attrs_if_leader_changed


  ### INSTANCE METHODS

  # Define methods to query if a course is in the given state.
  # eg course.canceled?
  possible_states.each do |state|
    define_method "#{state}?" do
      self.state == state
    end
  end

  def state
    super || possible_states.first
  end

  def abroad?
    canton == ABROAD_CANTON
  end

  def application_possible?
    super && participants_can_apply?
  end

  def cancel_possible?
    participants_can_cancel? && confirmed?
  end

  def default_participation_state(participation)
    if participation.roles.blank? ||
      participation.roles.any? { |role| role.kind != :participant } ||
      !paper_application_required?
      'assigned'
    else
      'applied_electronically'
    end
  end

  def camp_days
    count = 0
    dates.each do |d|
      count += event_date_day_count(d)
    end
    count
  end

  private

  def assign_abteilungsleitung
    if abteilungsleitung_id.blank? && abteilung.present? && abteilungsleitung_roles.count == 1
      self.abteilungsleitung_id = abteilungsleitung_roles.first.person.id
    end
  end

  def abteilung
    groups.first.hierarchy.find_by(type: Group::Abteilung.sti_name)
  end

  def abteilungsleitung_roles
    Group::Abteilung::Abteilungsleitung.where(group: abteilung)
  end

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

  def send_assignment_infos
    [:coach,
     :advisor_mountain_security,
     :advisor_snow_security,
     :advisor_water_security
    ].each do |advisor_key|
      send_advisor_assignment_info(advisor_key)
    end
  end

  def send_advisor_assignment_info(advisor_key)
    person = send(advisor_key)
    if person &&
       person != Person.stamper &&
       (state_changed_from_created? || advisor_changed_except_in_created?(advisor_key))
      Event::CampMailer.advisor_assigned(self, person, advisor_key.to_s, Person.stamper).
        deliver_later
    end
  end

  def state_changed_from_created?
    state_changed? && (state_change.first == 'created' || state_change.first.nil?)
  end

  def advisor_changed_except_in_created?(advisor_key)
    restricted_role_changes[advisor_key] && state != 'created' && !state.blank?
  end

  def send_abteilungsleitung_assignment_info
    if abteilungsleitung && abteilungsleitung != Person.stamper &&
       restricted_role_changes[:abteilungsleitung]
      Event::CampMailer.advisor_assigned(self, abteilungsleitung, 'abteilungsleitung',
                                         Person.stamper).deliver_later
    end
  end

  def send_created_infos
    layer_leaders.each { |person| send_created_info(person) }
  end

  def send_created_info(person)
    if person && person != Person.stamper &&
      (state_changed_from_created? && state == 'confirmed')
      Event::CampMailer.camp_created(self, person, Person.stamper).deliver_later
    end
  end

  def layer_leaders
    layer_group = groups.first.layer_group
    Person.joins(:roles, :groups)
          .where(roles: { type: layer_leader_roles[layer_group.class.sti_name] },
                 groups: { id: layer_group.id })
  end

  def layer_leader_roles
    @leader_roles ||= {
      Group::Bund.sti_name => Group::Bund::MitarbeiterGs.sti_name,
      Group::Kantonalverband.sti_name => Group::Kantonalverband::Kantonsleitung.sti_name,
      Group::Region.sti_name => Group::Region::Regionalleitung.sti_name,
      Group::Abteilung.sti_name => Group::Abteilung::Abteilungsleitung.sti_name
    }
  end

  def event_date_day_count(date)
    return 1 unless date.finish_at
    start_at = date.start_at.to_date
    finish_at = date.finish_at.to_date
    (finish_at - start_at).to_i + 1
  end

end
