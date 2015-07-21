# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::CanceledParticipationJob < BaseJob

  ORGANIZER_ROLES = [Group::Abteilung::Abteilungsleitung,
                     Group::Abteilung::AbteilungsleitungStv,
                     Group::Region::Regionalleitung,
                     Group::Region::VerantwortungAusbildung,
                     Group::Kantonalverband::Kantonsleitung,
                     Group::Kantonalverband::VerantwortungAusbildung,
                     Group::Bund::Geschaeftsleitung,
                     Group::Bund::LeitungKernaufgabeAusbildung]

  ABTEILUNGSLEITUNGS_ROLES = [Group::Abteilung::Abteilungsleitung,
                              Group::Abteilung::AbteilungsleitungStv]

  self.parameters = [:participation_id, :locale]

  def initialize(participation)
    super()
    @participation_id = participation.id
  end

  def perform
    return unless participation || !participation.canceled? # may have been deleted again

    set_locale
    send_notification
  end

  private

  def send_notification
    list = recipients
    binding.pry
    if list.present?
      Event::ParticipationMailer.canceled(participation, list).deliver
    end
  end

  def recipients
    abteilungsleiter + kurs_leiter + kurs_organisatoren
  end

  def abteilungsleiter
    result = []
    primary = participation.person.primary_group
    if primary
      abteilung = primary.hierarchy.find { |group| group.is_a?(Group::Abteilung) }
      if abteilung
        result = filter_role_types(abteilung.people, ABTEILUNGSLEITUNGS_ROLES)
      end
    end
    result
  end

  def kurs_leiter
    Person.joins(:event_participations => :roles).
           where(event_participations: { event_id: participation.event_id },
                 event_roles: { type: Event::Role::Leader.sti_name })
  end

  def kurs_organisatoren
    query = Person.where(roles: { group_id: participation.event.groups })
    filter_role_types(query, ORGANIZER_ROLES)
  end

  def filter_role_types(query, types)
    query.joins(:roles).where(roles: { type: types.collect(&:sti_name) })
  end

  def participation
    @participation ||= Event::Participation.find(@participation_id)
  end

end
