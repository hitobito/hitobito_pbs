# frozen_string_literal: true

#  Copyright (c) 2012-2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventAbility
  extend ActiveSupport::Concern

  CANTONAL_CAMP_LIST_ROLES = [Group::Kantonalverband::Kantonsleitung,
                              Group::Kantonalverband::VerantwortungKrisenteam].freeze

  ABROAD_CAMP_LIST_ROLES = [Group::Bund::InternationalCommissionerIcWagggs,
                            Group::Bund::InternationalCommissionerIcWosm].freeze

  CAMP_KRISENTEAM_ROLES = [Group::Kantonalverband::Kantonsleitung,
                           Group::Kantonalverband::Sekretariat,
                           Group::Kantonalverband::VerantwortungKrisenteam,
                           Group::Kantonalverband::MitgliedKrisenteam].freeze

  included do # rubocop:disable Metrics/BlockLength
    on(Event) do
      permission(:any).may(:modify_superior).if_education_responsible

      permission(:any).may(:show_camp_application).for_leaded_events
      permission(:any).may(:create_camp_application).for_coached_events
      permission(:any).may(:show_details).if_participating_as_leader_role_of_supercamp

      permission(:group_full).
        may(:show_camp_application, :show_details).
        in_same_group
      permission(:group_and_below_full).
        may(:show_camp_application, :show_details).
        in_same_group_or_below
      permission(:layer_full).
        may(:show_camp_application, :show_details).
        in_same_layer
      permission(:layer_and_below_full).
        may(:show_camp_application, :show_details).
        in_same_layer_or_below

      permission(:layer_and_below_full).
        may(:create, :destroy, :application_market, :qualify).
        in_same_layer_or_course_in_below_abteilung
    end

    on(Event::Course) do
      permission(:any).may(:manage_attendances).for_leaded_events
      permission(:any).may(:update, :qualifications_read).for_advised_courses
      permission(:any).
        may(:index_approvals).
        for_advised_or_participations_full_events

      permission(:layer_full).may(:manage_attendances, :index_approvals).in_same_layer

      permission(:layer_and_below_full).may(:manage_attendances).in_same_layer
      permission(:layer_and_below_full).may(:index_approvals).in_same_layer_or_below

      general(:manage_attendances).at_least_one_group_not_deleted
    end

    on(Event::Camp) do
      class_side(:list_all).if_mitarbeiter_gs
      class_side(:list_cantonal).if_kantonsleitung_or_krisenverantwortlich
      class_side(:list_abroad).if_international_commissioner

      permission(:any).may(:index_revoked_participations).for_participations_full_events
      permission(:any).may(:show_details).if_part_of_krisenteam
      permission(:any).may(:show_crisis_contacts).if_part_of_krisenteam

      permission(:any).may(:index_participations).like_in_core_or_as_leader_of_supercamp

      permission(:group_full).may(:index_revoked_participations).in_same_group
      permission(:group_and_below_full).may(:index_revoked_participations).in_same_group_or_below
      permission(:layer_full).may(:index_revoked_participations).in_same_layer
      permission(:layer_and_below_full).may(:index_revoked_participations).in_same_layer_or_below
    end

    alias_method_chain :if_full_permission_in_course_layer, :ausbildungskommission
    alias_method_chain :if_globally_visible_or_participating, :pbs
  end

  def if_globally_visible_or_participating_with_pbs
    if_globally_visible_or_participating_without_pbs || participating?
  end

  def for_advised_courses
    event.advisor_id == user.id
  end

  def if_education_responsible
    role_type?(Group::Bund::AssistenzAusbildung,
               Group::Bund::MitarbeiterGs)
  end

  def if_mitarbeiter_gs
    role_type?(Group::Bund::MitarbeiterGs)
  end

  def if_kantonsleitung_or_krisenverantwortlich
    role_type?(*CANTONAL_CAMP_LIST_ROLES)
  end

  def if_international_commissioner
    role_type?(*ABROAD_CAMP_LIST_ROLES)
  end

  def for_coached_events
    event.coach_id == user.id
  end

  def for_advised_or_participations_full_events
    for_advised_courses || for_participations_full_events
  end

  def like_in_core_or_as_leader_of_supercamp
    for_participations_read_events_and_course_participants ||
      if_participating_as_leader_role_of_supercamp
  end

  def if_participating_as_leader_role_of_supercamp
    participating? && participating_as_leader_role?
  end

  def if_part_of_krisenteam
    user.roles.where(type: CAMP_KRISENTEAM_ROLES, group: kantonalverbaende).exists?
  end

  def kantonalverbaende
    event.groups.collect(&:layer_hierarchy).flatten.select do |group|
      group.is_a?(Group::Kantonalverband)
    end + KantonalverbandCanton.where(canton: event.canton).collect(&:kantonalverband)
  end

  def relevant_participating_event_ids
    @relevant_participating_event_ids ||= begin
      relevant_event_ids = event.self_and_ancestors.pluck(:id)
      participating_event_ids = user_context.participations.collect(&:event_id)

      (participating_event_ids & relevant_event_ids)
    end
  end

  def participating?
    relevant_participating_event_ids.any?
  end

  def participating_as_leader_role?
    Event.where(id: relevant_participating_event_ids)
         .joins(participations: [:roles])
         .where('event_participations.person_id = ?', user.id)
         .where('event_roles.type != ?', Event::Camp::Role::Participant.sti_name)
         .present?
  end

  def if_full_permission_in_course_layer_with_ausbildungskommission
    if_full_permission_in_course_layer_without_ausbildungskommission ||
      role_type?(Group::Ausbildungskommission::Mitglied)
  end

end
