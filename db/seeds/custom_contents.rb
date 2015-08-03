# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

CustomContent.seed_once(:key,
  { key: GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP,
    placeholders_required: 'actuator-name, group-link',
    placeholders_optional: 'recipient-name' },

  { key: Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER,
    placeholders_required: 'event-details, application-url',
    placeholders_optional: 'recipient-name' },

  {key: Event::ParticipationMailer::CONTENT_CANCELED_PARTICIPATION,
   placeholders_required: 'participant-name',
   placeholders_optional: 'event-name, canceled-at, application-url, event-details'},

  {key: Event::ParticipationMailer::CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST,
   placeholders_required: 'participant-name',
   placeholders_optional: 'event-name, canceled-at, application-url, event-details, waiting-list-setter, leader-name'},

  {key: Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST,
   placeholders_required: 'participant-name',
   placeholders_optional: 'event-name, canceled-at, application-url, event-details, waiting-list-setter, leader-name'},
)

group_membership_id = CustomContent.get(GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP).id
participation_confirmation_other_id = CustomContent.get(Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER).id
participation_canceled_id = CustomContent.get(Event::ParticipationMailer::CONTENT_CANCELED_PARTICIPATION).id
participation_assigned_from_waiting_list_id = CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST).id
participation_removed_from_waiting_list_id = CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST).id

CustomContent::Translation.seed_once(:custom_content_id, :locale,
  { custom_content_id: group_membership_id,
    locale: 'de',
    label: 'Information bei neuer Gruppenzugehörigkeit',
    subject: "Aufnahme in Gruppe",
    body: "Hallo {recipient-name}<br/><br/>" \
          "{actuator-name} hat dich zur Gruppe {group-link} hinzugefügt.<br/><br/>" \
          "Bis bald!" },

  { custom_content_id: group_membership_id,
    locale: 'fr',
    label: 'Informations pour les nouveau membres du groupe',
    subject: 'Admission dans le groupe',
    body: "Salut {recipient-name}<br/><br/>" \
          "{actuator-name} t\'as ajouté au groupe {group-link}.<br/><br/>" \
          "A bientôt!"},

  { custom_content_id: group_membership_id,
    locale: 'it',
    label: 'Informazioni per la nuova appartenenza al gruppo' },

  { custom_content_id: participation_confirmation_other_id,
    locale: 'de',
    label: 'Anlass: E-Mail Fremdanmeldebestätigung',
    subject: 'Du wurdest angemeldet',
    body: "Hallo {recipient-name}<br/><br/>" \
          "Du wurdest für folgenden Anlass angemeldet:<br/><br/>" \
          "{event-details}<br/><br/>" \
          "Falls du ein Login hast, kannst du deine Anmeldung unter folgender Adresse einsehen " \
          "und eine Bestätigung ausdrucken:<br/><br/>{application-url}" },

  { custom_content_id: participation_confirmation_other_id,
    locale: 'fr',
    label: "Événement: Autre E-Mail de confirmation de l'inscription" },

  { custom_content_id: participation_confirmation_other_id,
    locale: 'en',
    label: 'Event: Other application confirmation email' },

  { custom_content_id: participation_confirmation_other_id,
    locale: 'it',
    label: "Evento: Altro E-mail per l'affermazione della inscrizione" },

  { custom_content_id: participation_canceled_id,
    locale: 'de',
    label: 'Anlass: E-Mail Abmeldung',
    subject: 'Kursabmeldung',
    body: "Hallo zusammen<br/><br/>" \
          "{participant-name} wurde per {canceled-at} vom Kurs {event-name} abgemeldet.<br/><br/>" \
          "Siehe {application-url}<br/><br/>" \
          "Kursdetails:<br/>{event-details}<br/>" },

  { custom_content_id: participation_canceled_id,
    locale: 'fr',
    label: "Événement: E-Mail d'annonce de départ" },

  { custom_content_id: participation_canceled_id,
    locale: 'en',
    label: 'Event: Unsubscription email' },

  { custom_content_id: participation_canceled_id,
    locale: 'it',
    label: "Evento: E-mail della notifica della partenza" },

  { custom_content_id: participation_assigned_from_waiting_list_id,
    locale: 'de',
    label: 'Anlass: E-Mail Teilnehmer/-in aus der Warteliste zuweisen',
    subject: 'Zuweisung aus Warteliste',
    body: "Hallo {waiting-list-setter}<br/><br/>" \
          "{participant-name} wurde von {leader-name} von der Warteliste in den Kurs {event-name} übernommen.<br/><br/>" \
          "Siehe {application-url}<br/><br/>" \
          "Kursdetails:<br/>{event-details}<br/>" },

  { custom_content_id: participation_assigned_from_waiting_list_id,
    locale: 'fr',
    label: "Événement: E-Mail Abonné a été assigné  de la liste d'attente" },

  { custom_content_id: participation_assigned_from_waiting_list_id,
    locale: 'en',
    label: 'Event: E-mail Participant assigned from waiting list' },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'it',
    label: "Evento: E-mail Abbonato è stato assegnato dalla lista d'attesa" },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'de',
    label: 'Anlass: E-Mail Teilnehmer/-in von der Warteliste nehmen',
    subject: 'Von der Warteliste genommen',
    body: "Hallo {waiting-list-setter}<br/><br/>" \
          "{participant-name} wurde von {leader-name} von der Warteliste genommen.<br/><br/>" \
          "Siehe {application-url}<br/><br/>" \
          "Kursdetails:<br/>{event-details}<br/>" },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'fr',
    label: "Événement: E-Mail Abonné a été supprimé de la liste d'attente" },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'en',
    label: 'Event: E-mail Participant Removed from waiting list' },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'it',
    label: "Evento: E-mail Abbonato è stato rimosso dalla lista di attesa" },
)

