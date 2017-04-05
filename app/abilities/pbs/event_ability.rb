# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventAbility
  extend ActiveSupport::Concern

  CANTONAL_CAMP_LIST_ROLES = [Group::Kantonalverband::Kantonsleitung,
                              Group::Kantonalverband::VerantwortungKrisenteam].freeze

  ABROAD_CAMP_LIST_ROLES = [Group::Bund::InternationalCommissionerIcWagggs,
                            Group::Bund::InternationalCommissionerIcWosm].freeze

  included do
    on(Event) do
      permission(:any).may(:modify_superior).if_education_responsible

      permission(:any).may(:show_camp_application).for_leaded_events
      permission(:any).may(:create_camp_application).for_coached_events
      permission(:any).may(:show_details).if_participating_as_leader_role

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

      permission(:layer_full).may(:manage_attendances).in_same_layer

      permission(:layer_and_below_full).may(:manage_attendances).in_same_layer

      general(:manage_attendances).at_least_one_group_not_deleted
    end

    on(Event::Camp) do
      class_side(:list_all).if_mitarbeiter_gs
      class_side(:list_cantonal).if_kantonsleitung_or_krisenverantwortlich
      class_side(:list_abroad).if_international_commissioner

      permission(:any).may(:index_revoked_participations).for_participations_full_events

      permission(:group_full).may(:index_revoked_participations).in_same_group
      permission(:group_and_below_full).may(:index_revoked_participations,).in_same_group_or_below
      permission(:layer_full).may(:index_revoked_participations).in_same_layer
      permission(:layer_and_below_full).may(:index_revoked_participations).in_same_layer_or_below
    end

    alias_method_chain :if_full_permission_in_course_layer, :ausbildungskommission
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

  def if_participating_as_leader_role
    participating? && participating_as_leader_role?
  end

  def participating?
    user_context.participations.collect(&:event_id).include?(event.id)
  end

  def participating_as_leader_role?
    event.participations.
      where(person: user).
      joins(:roles).
      where('event_roles.type != ?', Event::Camp::Role::Participant.sti_name).
      present?
  end

  def if_full_permission_in_course_layer_with_ausbildungskommission
    if_full_permission_in_course_layer_without_ausbildungskommission ||
      role_type?(Group::Ausbildungskommission::Mitglied)
  end

end
