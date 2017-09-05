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
#  description                       :text(65535)
#  location                          :text(65535)
#  application_opening_at            :date
#  application_closing_at            :date
#  application_conditions            :text(65535)
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
#  creator_id                        :integer
#  updater_id                        :integer
#  applications_cancelable           :boolean          default(FALSE), not null
#  training_days                     :decimal(12, 1)
#  tentative_applications            :boolean          default(FALSE), not null
#  language_de                       :boolean          default(FALSE), not null
#  language_fr                       :boolean          default(FALSE), not null
#  language_it                       :boolean          default(FALSE), not null
#  language_en                       :boolean          default(FALSE), not null
#  express_fee                       :string
#  requires_approval_abteilung       :boolean          default(FALSE), not null
#  requires_approval_region          :boolean          default(FALSE), not null
#  requires_approval_kantonalverband :boolean          default(FALSE), not null
#  requires_approval_bund            :boolean          default(FALSE), not null
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
#  j_s_kind                          :string
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
#  lagerreglement_applied            :boolean          default(FALSE), not null
#  kantonalverband_rules_applied     :boolean          default(FALSE), not null
#  j_s_rules_applied                 :boolean          default(FALSE), not null
#  required_contact_attrs            :text
#  hidden_contact_attrs              :text
#  display_booking_info              :boolean          default(TRUE), not null
#  bsv_days                          :decimal(6, 2)
#

class Event::Camp < Event

  # This statement is required because this class would not be loaded otherwise.
  require_dependency 'event/camp/role/helper'
  require_dependency 'event/camp/role/participant'

  include Event::RestrictedRole

  self.used_attributes += [:state, :group_ids,
                           :participants_can_apply, :participants_can_cancel]

  self.used_attributes -= [:contact_id, :applications_cancelable]

  self.role_types = [Event::Camp::Role::AssistantLeader,
                     Event::Camp::Role::Helper,
                     Event::Camp::Role::Participant]

  # include only after main role types are defined
  include Event::Campy

  # states are used for workflow
  # translations in config/locales
  self.possible_states = %w(created confirmed assignment_closed canceled closed)
  self.possible_participation_states = %w(applied_electronically assigned canceled absent)
  self.active_participation_states = %w(applied_electronically assigned)
  self.revoked_participation_states = %w(canceled absent)
  self.countable_participation_states = %w(applied_electronically assigned absent)


  ### VALIDATIONS

  validates :state, inclusion: possible_states

  ### CALLBACKS

  before_create :assign_abteilungsleitung
  after_save :send_assignment_infos
  after_save :send_abteilungsleitung_assignment_info
  after_save :send_created_infos


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

  def application_possible?
    super && participants_can_apply?
  end

  def cancel_possible?
    participants_can_cancel? && confirmed?
  end

  def default_participation_state(participation, _for_someone_else = false)
    if participation.roles.blank? ||
      participation.roles.any? { |role| role.kind != :participant } ||
      !paper_application_required?
      'assigned'
    else
      'applied_electronically'
    end
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

end
