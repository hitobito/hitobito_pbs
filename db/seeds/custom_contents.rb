# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

CustomContent.seed_once(:key,
  { key: GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP,
    placeholders_required: 'actuator-name, group-link',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name' },

  { key: Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER,
    placeholders_required: 'event-details, application-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name' },

  { key: Event::ParticipationMailer::CONTENT_CANCELED_PARTICIPATION,
    placeholders_required: 'participant-name',
    placeholders_optional: 'event-name, canceled-at, application-url, event-details' },

  { key: Event::ParticipationMailer::CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST,
    placeholders_required: 'participant-name',
    placeholders_optional: 'event-name, canceled-at, application-url, event-details, waiting-list-setter, leader-name' },

  { key: Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST,
    placeholders_required: 'participant-name',
    placeholders_optional: 'event-name, canceled-at, application-url, event-details, waiting-list-setter, leader-name' },

  { key: Event::CampMailer::CONTENT_CAMP_CREATED,
    placeholders_required: 'actuator-name, camp-url',
    placeholders_optional: 'camp-name, camp-state' },

  { key: Event::CampMailer::CONTENT_COACH_ASSIGNED,
    placeholders_required: 'actuator-name, advisor-name, camp-url',
    placeholders_optional: 'camp-name, camp-state' },

  { key: Event::CampMailer::CONTENT_SECURITY_ADVISOR_ASSIGNED,
    placeholders_required: 'actuator-name, advisor-name, camp-url',
    placeholders_optional: 'camp-name, camp-state' },

  { key: Event::CampMailer::CONTENT_AL_ASSIGNED,
    placeholders_required: 'actuator-name, advisor-name, camp-url',
    placeholders_optional: 'camp-name, camp-state' },

  { key: Event::CampMailer::CONTENT_SUBMIT_REMINDER,
    placeholders_required: 'camp-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, camp-name, camp-state' },

  { key: Event::CampMailer::CONTENT_SUBMIT,
    placeholders_required: 'camp-url',
    placeholders_optional: 'coach-name, camp-name, camp-state, camp-application-url' },

  { key: Event::CampMailer::CONTENT_PARTICIPANT_APPLIED,
    placeholders_required: 'participant-name, camp-url',
    placeholders_optional: 'camp-name, camp-state' },

  { key: Event::CampMailer::CONTENT_PARTICIPANT_CANCELED,
    placeholders_required: 'participant-name, camp-url',
    placeholders_optional: 'camp-name, camp-state' }
)

# update these contents from hitobito-core, always, to supersede (haha) the seeds from hitobito-core
CustomContent.seed(:key,
  { key: Person::LoginMailer::CONTENT_LOGIN,
    placeholders_required: 'login-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, sender-name'},

  { key: Event::ParticipationMailer::CONTENT_CONFIRMATION,
    placeholders_required: 'event-details, application-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name'},

  { key: Event::ParticipationMailer::CONTENT_APPROVAL,
    placeholders_required: 'participant-name, event-details, application-url',
    placeholders_optional: 'recipient-names-with-salutation, recipient-names'},

  { key: Event::ParticipationMailer::CONTENT_CANCEL,
    placeholders_required: 'event-details',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name'},

  { key: Event::RegisterMailer::CONTENT_REGISTER_LOGIN,
    placeholders_required: 'event-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, event-name'},

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_PERSON,
    placeholders_required: 'request-body, answer-request-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, requester-name, requester-roles' },

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_RESPONSIBLES,
    placeholders_required: 'person-name, request-body, answer-request-url',
    placeholders_optional: 'recipient-names-with-salutation, recipient-names, requester-name, requester-roles' },

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_APPROVED,
    placeholders_required: 'person-name, request-body',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, approver-name, approver-roles' },

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_REJECTED,
    placeholders_required: 'person-name, request-body',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, rejecter-name, rejecter-roles' },
)

group_membership_id = CustomContent.get(GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP).id
participation_confirmation_other_id = CustomContent.get(Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER).id
participation_canceled_id = CustomContent.get(Event::ParticipationMailer::CONTENT_CANCELED_PARTICIPATION).id
participation_assigned_from_waiting_list_id = CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST).id
participation_removed_from_waiting_list_id = CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST).id


camp_created_id = CustomContent.get(Event::CampMailer::CONTENT_CAMP_CREATED).id
camp_coach_assigned_id = CustomContent.get(Event::CampMailer::CONTENT_COACH_ASSIGNED ).id
camp_security_advisor_assigned_id = CustomContent.
  get(Event::CampMailer::CONTENT_SECURITY_ADVISOR_ASSIGNED).id
camp_al_assigned_id = CustomContent.get(Event::CampMailer::CONTENT_AL_ASSIGNED).id
camp_submit_reminder_id = CustomContent.get(Event::CampMailer::CONTENT_SUBMIT_REMINDER).id
camp_submit_id = CustomContent.get(Event::CampMailer::CONTENT_SUBMIT).id
camp_participant_applied_id = CustomContent.get(Event::CampMailer::CONTENT_PARTICIPANT_APPLIED).id
camp_participant_canceled_id = CustomContent.
  get(Event::CampMailer::CONTENT_PARTICIPANT_CANCELED).id

send_login_id = CustomContent.get(Person::LoginMailer::CONTENT_LOGIN).id
participation_confirmation_id = CustomContent.get(Event::ParticipationMailer::CONTENT_CONFIRMATION).id
participation_approval_id = CustomContent.get(Event::ParticipationMailer::CONTENT_APPROVAL).id
cancel_application_id = CustomContent.get(Event::ParticipationMailer::CONTENT_CANCEL).id
temp_login_id = CustomContent.get(Event::RegisterMailer::CONTENT_REGISTER_LOGIN).id
add_request_person_id = CustomContent.get(Person::AddRequestMailer::CONTENT_ADD_REQUEST_PERSON).id
add_request_responsibles_id = CustomContent.get(Person::AddRequestMailer::CONTENT_ADD_REQUEST_RESPONSIBLES).id
add_request_approved_id = CustomContent.get(Person::AddRequestMailer::CONTENT_ADD_REQUEST_APPROVED).id
add_request_rejected_id = CustomContent.get(Person::AddRequestMailer::CONTENT_ADD_REQUEST_REJECTED).id

_id = CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST).id

CustomContent::Translation.seed_once(:custom_content_id, :locale,
  { custom_content_id: group_membership_id,
    locale: 'de',
    label: 'Information bei neuer Gruppenzugehörigkeit',
    subject: "Aufnahme in Gruppe",
    body: "{recipient-name-with-salutation}<br/><br/>" \
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
    locale: 'en',
    label: 'Added to Group' },

  { custom_content_id: group_membership_id,
    locale: 'it',
    label: 'Informazioni per la nuova appartenenza al gruppo' },

  { custom_content_id: participation_confirmation_other_id,
    locale: 'de',
    label: 'Anlass: E-Mail Fremdanmeldebestätigung',
    subject: 'Du wurdest angemeldet',
    body: "{recipient-name-with-salutation}<br/><br/>" \
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

  { custom_content_id: participation_assigned_from_waiting_list_id,
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

  { custom_content_id: camp_created_id,
    locale: 'de',
    label: 'Lager: E-Mail Lager erstellt',
    subject: 'Lager wurde erstellt',
    body: 'Hallo<br><br>' \
          'Das Lager "{camp-name}" wurde von {actuator-name} erstellt:<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_created_id,
    locale: 'fr',
    label: 'Camp: E-Mail camp créé'},

  { custom_content_id: camp_created_id,
    locale: 'en',
    label: 'Camp: Email camp created'},

  { custom_content_id: camp_created_id,
    locale: 'it',
    label: 'Campo: E-Mail campo creato'},

  { custom_content_id: camp_coach_assigned_id,
    locale: 'de',
    label: 'Lager: E-Mail Coach zugeordnet',
    subject: 'Lager: Coach zugeordnet',
    body: 'Hallo<br><br>' \
          '{actuator-name} hat im Lager "{camp-name}" {advisor-name} als Coach definiert.<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_coach_assigned_id,
    locale: 'fr',
    label: 'Camp: E-Mail Coach assigné'},

  { custom_content_id: camp_coach_assigned_id,
    locale: 'en',
    label: 'Camp: Email Coach assigned'},

  { custom_content_id: camp_coach_assigned_id,
    locale: 'it',
    label: 'Campo: E-Mail Coach assegnato'},

  { custom_content_id: camp_security_advisor_assigned_id,
    locale: 'de',
    label: 'Lager: E-Mail Sicherheitsbereich Betreuung zugeordnet',
    subject: 'Lager: Sicherheitsbereich Betreuung zugeordnet',
    body: 'Hallo<br><br>' \
          '{actuator-name} hat im Lager "{camp-name}" {advisor-name} als Sicherheitsbereich ' \
          'Betreuung definiert.<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_security_advisor_assigned_id,
    locale: 'fr',
    label: 'Camp: E-Mail encadrement Domaine de la Sécurité assigné'},

  { custom_content_id: camp_security_advisor_assigned_id,
    locale: 'en',
    label: 'Camp: Email security scope support assigned'},

  { custom_content_id: camp_security_advisor_assigned_id,
    locale: 'it',
    label: 'Campo: E-Mail cura zona di sicurezza assegnato'},

  { custom_content_id: camp_al_assigned_id,
    locale: 'de',
    label: 'Lager: E-Mail Abteilungsleitung zugeordnet',
    subject: 'Lager: Abteilungsleitung zugeordnet',
    body: 'Hallo<br><br>' \
          '{actuator-name} hat im Lager "{camp-name}" {advisor-name} als Abteilungsleitung ' \
          'definiert.<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_al_assigned_id,
    locale: 'fr',
    label: 'Camp: E-Mail responsable de groupe assigné'},

  { custom_content_id: camp_al_assigned_id,
    locale: 'en',
    label: 'Camp: Email group officer assigned'},

  { custom_content_id: camp_al_assigned_id,
    locale: 'it',
    label: 'Campo: E-Mail Capo sezione assegnato'},

  { custom_content_id: camp_submit_reminder_id,
    locale: 'de',
    label: 'Lager: E-Mail Lager einreichen Erinnerung',
    subject: 'Lager: Lager einreichen Erinnerung',
    body: '{recipient-name-with-salutation}<br><br>' \
          'Das Lager "{camp-name}" muss noch an PBS eingereicht werden:<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_submit_reminder_id,
    locale: 'fr',
    label: 'Camp: E-Mail évoquer déposer de camp'},

  { custom_content_id: camp_submit_reminder_id,
    locale: 'en',
    label: 'Camp: Email submit camp reminder'},

  { custom_content_id: camp_submit_reminder_id,
    locale: 'it',
    label: 'Campo: E-Mail promemoria presentare campo'},

  { custom_content_id: camp_submit_id,
    locale: 'de',
    label: 'Lager: E-Mail Lager einreichen',
    subject: 'Einreichung Lager',
    body: 'Hallo<br><br>' \
          '{coach-name} reicht das Lager "{camp-name}" ein.<br><br>' \
          'PDF: {camp-application-url}<br>' \
          'Lager: {camp-url}<br>' },

  { custom_content_id: camp_submit_id,
    locale: 'fr',
    label: 'Camp: E-Mail déposer de camp'},

  { custom_content_id: camp_submit_id,
    locale: 'en',
    label: 'Camp: Email camp submit'},

  { custom_content_id: camp_submit_id,
    locale: 'it',
    label: 'Campo: E-Mail presentare campo'},

  { custom_content_id: camp_participant_applied_id,
    locale: 'de',
    label: 'Lager: E-Mail Teilnehmer-/in hat sich angemeldet',
    subject: 'Lager: Teilnehmer-/in hat sich angemeldet',
    body: 'Hallo<br><br>' \
          '{participant-name} hat sich für das Lager "{camp-name}" angemeldet:<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_participant_applied_id,
    locale: 'fr',
    label: 'Camp: E-Mail Participant/-e a enregistré'},

  { custom_content_id: camp_participant_applied_id,
    locale: 'en',
    label: 'Camp: E-Mail Participant has applied'},

  { custom_content_id: camp_participant_applied_id,
    locale: 'it',
    label: 'Campo: E-Mail Participante ha registrato'},

  { custom_content_id: camp_participant_canceled_id,
    locale: 'de',
    label: 'Lager: E-Mail Teilnehmer-/in hat sich abgemeldet',
    subject: 'Lager: Teilnehmer-/in hat sich abgemeldet',
    body: 'Hallo<br><br>' \
          '{participant-name} hat sich vom Lager "{camp-name}" abgemeldet:<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_participant_canceled_id,
    locale: 'fr',
    label: 'Camp: E-Mail Participant/-e a disputer'},

  { custom_content_id: camp_participant_canceled_id,
    locale: 'en',
    label: 'Camp: Email Participant has unsubscribed'},

  { custom_content_id: camp_participant_canceled_id,
    locale: 'it',
    label: 'Campo: E-Mail Participante ha annullare'}
)

# reseed always to have decent test-data
CustomContent::Translation.seed(:custom_content_id, :locale,

  {custom_content_id: send_login_id,
   locale: 'de',
   label: 'Login senden',
   subject: "Willkommen bei #{Settings.application.name}",
   body: "{recipient-name-with-salutation}<br/><br/>" \
         "Willkommen bei #{Settings.application.name}! Unter dem folgenden Link kannst du " \
         "dein Login Passwort setzen:<br/><br/>{login-url}<br/><br/>" \
         "Bis bald!<br/><br/>{sender-name}" },

  {custom_content_id: participation_confirmation_id,
   locale: 'de',
   label: 'Anlass: E-Mail Anmeldebestätigung',
   subject: 'Bestätigung der Anmeldung',
   body: "{recipient-name-with-salutation}<br/><br/>" \
         "Du hast dich für folgenden Anlass angemeldet:<br/><br/>" \
         "{event-details}<br/><br/>" \
         "Falls du ein Login hast, kannst du deine Anmeldung unter folgender Adresse einsehen " \
         "und eine Bestätigung ausdrucken:<br/><br/>{application-url}" },

  {custom_content_id: cancel_application_id,
   locale: 'de',
   label: 'Anlass: E-Mail Abmeldebestätigung',
   subject: 'Bestätigung der Abmeldung',
   body: "{recipient-name-with-salutation}<br/><br/>" \
         "Du hast dich von folgendem Anlass abgemeldet:<br/><br/>" \
         "{event-details}<br/><br/>"},

  {custom_content_id: participation_approval_id,
   locale: 'de',
   label: 'Anlass: E-Mail Freigabe der Anmeldung',
   subject: 'Freigabe einer Kursanmeldung',
   body: "{recipient-names-with-salutation}<br/><br/>" \
         "{participant-name} hat sich für den folgenden Kurs angemeldet:<br/><br/>" \
         "{event-details}<br/><br/>" \
         "Bitte bestätige oder verwerfe diese Anmeldung unter der folgenden Adresse:<br/><br/>" \
        "{application-url}" },

  {custom_content_id: temp_login_id,
   locale: 'de',
   label: 'Anlass: Temporäres Login senden',
   subject: 'Anmeldelink für Anlass',
   body: "{recipient-name-with-salutation}<br/><br/>" \
         "Hier kannst du dich für den Anlass {event-name} anmelden:<br/><br/>" \
         "{event-url}<br/><br/>" \
         "Wir freuen uns, dich wieder mit dabei zu haben." },

  {custom_content_id: add_request_person_id,
   locale: 'de',
   label: 'Anfrage Personendaten: E-Mail Freigabe durch Person',
   subject: 'Freigabe deiner Personendaten',
   body: "{recipient-name-with-salutation}<br/><br/>" \
         "{requester-name} möchte dich hier hinzufügen: <br/><br/>" \
         "{request-body}<br/><br/>" \
         "{requester-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
         "{requester-roles}<br/><br/>" \
         "Bitte bestätige oder verwerfe diese Anfrage:<br/><br/>" \
         "{answer-request-url}" },

  {custom_content_id: add_request_responsibles_id,
   locale: 'de',
   label: 'Anfrage Personendaten: E-Mail Freigabe durch Verantwortliche',
   subject: 'Freigabe Personendaten',
   body: "{recipient-names-with-salutation}<br/><br/>" \
         "{requester-name} möchte {person-name} hier hinzufügen: <br/><br/>" \
         "{request-body}<br/><br/>" \
         "{requester-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
         "{requester-roles}<br/><br/>" \
         "Bitte bestätige oder verwerfe diese Anfrage:<br/><br/>" \
         "{answer-request-url}" },

  {custom_content_id: add_request_approved_id,
   locale: 'de',
   label: 'Anfrage Personendaten: E-Mail Freigabe akzeptiert',
   subject: 'Freigabe der Personendaten akzeptiert',
   body: "{recipient-name-with-salutation}<br/><br/>" \
         "{approver-name} hat deine Anfrage für {person-name} freigegeben.<br/><br/>" \
         "{person-name} wurde zu {request-body} hinzugefügt.<br/><br/>" \
         "{approver-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
         "{approver-roles}<br/><br/>" },

  {custom_content_id: add_request_rejected_id,
   locale: 'de',
   label: 'Anfrage Personendaten: E-Mail Freigabe abgelehnt',
   subject: 'Freigabe der Personendaten abgelehnt',
   body: "{recipient-name-with-salutation}<br/><br/>" \
         "{rejecter-name} hat deine Anfrage für {person-name} abgelehnt.<br/><br/>" \
         "{person-name} wird nicht zu {request-body} hinzugefügt.<br/><br/>" \
         "{rejecter-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
         "{rejecter-roles}<br/><br/>" },

)
