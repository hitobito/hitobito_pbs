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
    label: "Événement: E-Mail de confirmation de l'inscription par une autre personne" },

  { custom_content_id: participation_confirmation_other_id,
    locale: 'en',
    label: 'Event: Application confirmation email for a different person' },

  { custom_content_id: participation_confirmation_other_id,
    locale: 'it',
    label: "Evento: E-mail per l'affermazione della inscrizione per una altra persona" },

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
    label: 'Anlass: E-Mail Teilnehmer/-in aus der Warteliste zugewiesen',
    subject: 'Zuweisung aus Warteliste',
    body: "Hallo {waiting-list-setter}<br/><br/>" \
          "{participant-name} wurde von {leader-name} von der Warteliste in den Kurs {event-name} übernommen.<br/><br/>" \
          "Siehe {application-url}<br/><br/>" \
          "Kursdetails:<br/>{event-details}<br/>" },

  { custom_content_id: participation_assigned_from_waiting_list_id,
    locale: 'fr',
    label: "Événement: E-Mail participant/-e de la liste d'attente assigné/-e" },

  { custom_content_id: participation_assigned_from_waiting_list_id,
    locale: 'en',
    label: 'Event: Email participant assigned from waiting list' },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'it',
    label: "Evento: E-mail partecipante dalla lista d'attesa assegnato" },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'de',
    label: 'Anlass: E-Mail Teilnehmer/-in von der Warteliste entfernt',
    subject: 'Von der Warteliste entfernt',
    body: "Hallo {waiting-list-setter}<br/><br/>" \
          "{participant-name} wurde von {leader-name} von der Warteliste entfernt.<br/><br/>" \
          "Siehe {application-url}<br/><br/>" \
          "Kursdetails:<br/>{event-details}<br/>" },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'fr',
    label: "Événement: E-Mail participant/-e supprimé de la liste d'attente" },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'en',
    label: 'Event: Email participant removed from waiting list' },

  { custom_content_id: participation_removed_from_waiting_list_id,
    locale: 'it',
    label: "Evento: E-mail partecipante rimosso dalla lista d'attesa" },
)

