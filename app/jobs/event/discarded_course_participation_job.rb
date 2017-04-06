# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Job that sends mails for canceled or rejected course participations
class Event::DiscardedCourseParticipationJob < BaseJob

  ORGANIZER_ROLES = [Group::Abteilung::Abteilungsleitung,
                     Group::Abteilung::AbteilungsleitungStv,
                     Group::Region::Regionalleitung,
                     Group::Region::VerantwortungAusbildung,
                     Group::Kantonalverband::Kantonsleitung,
                     Group::Kantonalverband::VerantwortungAusbildung].freeze

  ABTEILUNGSLEITUNGS_ROLES = [Group::Abteilung::Abteilungsleitung,
                              Group::Abteilung::AbteilungsleitungStv].freeze

  self.parameters = [:participation_id, :locale]

  def initialize(participation)
    super()
    @participation_id = participation.id
  end

  def perform
    return if participation.nil? || (!canceled? && !rejected?) # may have been deleted again

    set_locale
    send_notification
  end

  private

  def send_notification
    list = recipients
    if list.present?
      Event::ParticipationMailer.send(participation.state, participation, list).deliver_now
    end
  end

  def recipients
    result = application_approvers
    result += abteilungsleiter + kurs_leiter + kurs_organisatoren if canceled?
    result.uniq
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
    Person.joins(event_participations: :roles)
          .where(event_participations: { event_id: participation.event_id },
                 event_roles: { type: Event::Course::Role::Leader.sti_name })
  end

  def kurs_organisatoren
    query = Person.where(roles: { group_id: participation.event.groups })
    filter_role_types(query, ORGANIZER_ROLES)
  end

  def application_approvers
    Person
      .joins('INNER JOIN event_approvals appr ON appr.approver_id = people.id')
      .joins('INNER JOIN event_participations p ON p.application_id = appr.application_id')
      .where('p.id = ? AND appr.approved = ?', participation.id, true)
  end

  def filter_role_types(query, types)
    query.includes(:roles).where(roles: { type: types.collect(&:sti_name) })
  end

  def participation
    @participation ||= Event::Participation.where(id: @participation_id).first
  end

  def canceled?
    participation.state == 'canceled'
  end

  def rejected?
    participation.state == 'rejected'
  end

end
