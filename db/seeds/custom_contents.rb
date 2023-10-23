# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

CustomContent.seed_once(:key,
  { key: AlumniMailer::CONTENT_INVITATION_WITH_REGIONAL_GROUPS,
    placeholders_required: 'person-name, SiScRegion-Links, AlumniGroup-Links' },

  { key: AlumniMailer::CONTENT_INVITATION_WITHOUT_REGIONAL_GROUPS,
    placeholders_required: 'person-name, SiScRegion-Links' },

  { key: AlumniMailer::CONTENT_REMINDER_WITH_REGIONAL_GROUPS,
    placeholders_required: 'person-name, SiScRegion-Links, AlumniGroup-Links' },

  { key: AlumniMailer::CONTENT_REMINDER_WITHOUT_REGIONAL_GROUPS,
    placeholders_required: 'person-name, SiScRegion-Links' },

  { key: GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP,
    placeholders_required: 'actuator-name, group-link',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name' },

  { key: Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER,
    placeholders_required: 'event-details, application-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name' },

  { key: Event::ParticipationMailer::CONTENT_CANCELED_PARTICIPATION,
    placeholders_required: 'participant-name',
    placeholders_optional: 'event-name, canceled-at, application-url, event-details' },

  { key: Event::ParticipationMailer::CONTENT_REJECTED_PARTICIPATION,
    placeholders_required: 'participant-name',
    placeholders_optional: 'event-name, application-url, event-details' },

  { key: Event::ParticipationMailer::CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST,
    placeholders_required: 'participant-name',
    placeholders_optional: 'event-name, application-url, event-details, waiting-list-setter, leader-name' },

  { key: Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST,
    placeholders_required: 'participant-name',
    placeholders_optional: 'event-name, application-url, event-details, waiting-list-setter, leader-name' },

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
    placeholders_optional: 'camp-name, camp-state' },

  { key: BlackListMailer::CONTENT_BLACK_LIST_HIT,
    placeholders_required: 'black-list-person, joined-target',
    placeholders_optional: '' },

  { key: BlackListMailer::CONTENT_BLACK_LIST_ATTR_HIT,
    placeholders_required: 'black-list-person',
    placeholders_optional: '' },

  { key: CrisisMailer::CONTENT_CRISIS_TRIGGERED,
    placeholders_required: 'creator, group',
    placeholders_optional: 'date' },

  { key: CrisisMailer::CONTENT_CRISIS_ACKNOWLEDGED,
    placeholders_required: 'creator, group, acknowledger',
    placeholders_optional: 'date' },

  { key: Event::Course::ConfirmationMailer::CONTENT_COURSE_CONFIRMATION,
    placeholders_required: 'participation-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, course-name' },

  { key: Group::Abteilung::CONTENT_GROUPFINDER_FIELDS_INFO,
    placeholders_required: '',
    placeholders_optional: 'max-number-of-geolocations' },

  { key: 'views/devise/sessions/info',
    placeholders_required: nil,
    placeholders_optional: nil },
)

invitation_with_regional_groups_id =
  CustomContent.get(AlumniMailer::CONTENT_INVITATION_WITH_REGIONAL_GROUPS).id
invitation_without_regional_groups_id =
  CustomContent.get(AlumniMailer::CONTENT_INVITATION_WITHOUT_REGIONAL_GROUPS).id
reminder_with_regional_groups_id =
  CustomContent.get(AlumniMailer::CONTENT_REMINDER_WITH_REGIONAL_GROUPS).id
reminder_without_regional_groups_id =
  CustomContent.get(AlumniMailer::CONTENT_REMINDER_WITHOUT_REGIONAL_GROUPS).id

group_membership_id = CustomContent.get(GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP).id

participation_confirmation_other_id =
  CustomContent.get(Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER).id
participation_canceled_id =
  CustomContent.get(Event::ParticipationMailer::CONTENT_CANCELED_PARTICIPATION).id
participation_rejected_id =
  CustomContent.get(Event::ParticipationMailer::CONTENT_REJECTED_PARTICIPATION).id
participation_assigned_from_waiting_list_id =
  CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST).id
participation_removed_from_waiting_list_id =
  CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST).id


camp_created_id = CustomContent.get(Event::CampMailer::CONTENT_CAMP_CREATED).id
camp_coach_assigned_id = CustomContent.get(Event::CampMailer::CONTENT_COACH_ASSIGNED).id
camp_security_advisor_assigned_id =
  CustomContent.get(Event::CampMailer::CONTENT_SECURITY_ADVISOR_ASSIGNED).id
camp_al_assigned_id = CustomContent.get(Event::CampMailer::CONTENT_AL_ASSIGNED).id
camp_submit_reminder_id = CustomContent.get(Event::CampMailer::CONTENT_SUBMIT_REMINDER).id
camp_submit_id = CustomContent.get(Event::CampMailer::CONTENT_SUBMIT).id
camp_participant_applied_id = CustomContent.get(Event::CampMailer::CONTENT_PARTICIPANT_APPLIED).id
camp_participant_canceled_id = CustomContent.
  get(Event::CampMailer::CONTENT_PARTICIPANT_CANCELED).id

black_list_hit_id = CustomContent.get(BlackListMailer::CONTENT_BLACK_LIST_HIT).id
black_list_attr_hit_id = CustomContent.get(BlackListMailer::CONTENT_BLACK_LIST_ATTR_HIT).id
crisis_triggered_id = CustomContent.get(CrisisMailer::CONTENT_CRISIS_TRIGGERED).id
crisis_acknowledged_id = CustomContent.get(CrisisMailer::CONTENT_CRISIS_ACKNOWLEDGED).id

course_confirmation_id = CustomContent.get(Event::Course::ConfirmationMailer::CONTENT_COURSE_CONFIRMATION).id

groupfinder_fields_info_id = CustomContent.get(Group::Abteilung::CONTENT_GROUPFINDER_FIELDS_INFO).id

_id =
  CustomContent.get(Event::ParticipationMailer::CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST).id

CustomContent::Translation.seed_once(:custom_content_id, :locale,
  { custom_content_id: invitation_with_regional_groups_id,
    locale: 'de',
    label: 'Silverscouts/Ehemalige Einladungsmail',
    subject: "Ehemalige Einladung zur Selbstregistrierung",
    body: "Silverscouts Selbstregistrierung:<br/>{SiScRegion-Links}<br/><br/>" \
        "Ehemalige-Gruppen Selbstregistrierung:<br/>{AlumniGroup-Links}<br/><br/>" },

  { custom_content_id: invitation_without_regional_groups_id,
    locale: 'de',
    label: 'Ehemalige Einladungsmail ohne Silverscouts',
    subject: "Ehemalige Einladung zur Selbstregistrierung",
    body: "Ehemalige-Gruppen Selbstregistrierung:<br/>{AlumniGroup-Links}" },

  { custom_content_id: reminder_with_regional_groups_id,
    locale: 'de',
    label: 'Silverscouts/Ehemalige Erinnerungsmail',
    subject: "Ehemalige Erinnerung zur Selbstregistrierung",
    body: "Erinnerung<br/><br/>Silverscouts Selbstregistrierung:<br/>{SiScRegion-Links}<br/><br/>" \
        "Ehemalige-Gruppen Selbstregistrierung:<br/>{AlumniGroup-Links}<br/><br/>" },

  { custom_content_id: reminder_without_regional_groups_id,
    locale: 'de',
    label: 'Ehemalige Erinnerungsmail ohne Silverscouts',
    subject: "Ehemalige Erinnerung zur Selbstregistrierung",
    body: "Erinnerung<br/><br/>Ehemalige-Gruppen Selbstregistrierung:<br/>{AlumniGroup-Links}" },

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
          "A bientôt!" },

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

  { custom_content_id: participation_rejected_id,
    locale: 'de',
    label: 'Anlass: E-Mail Ablehnung',
    subject: 'Kursablehnung',
    body: "Hallo zusammen<br/><br/>" \
          "{participant-name} wurde für den Kurs {event-name} abgelehnt.<br/><br/>" \
          "Siehe {application-url}<br/><br/>" \
          "Kursdetails:<br/>{event-details}<br/>" },

  { custom_content_id: participation_rejected_id,
    locale: 'fr',
    label: "Événement: E-Mail de refus" },

  { custom_content_id: participation_rejected_id,
    locale: 'en',
    label: 'Event: Rejection email' },

  { custom_content_id: participation_rejected_id,
    locale: 'it',
    label: "Evento: E-mail della notifica della rifiuto" },

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
    label: 'Camp: E-Mail camp créé' },

  { custom_content_id: camp_created_id,
    locale: 'en',
    label: 'Camp: Email camp created' },

  { custom_content_id: camp_created_id,
    locale: 'it',
    label: 'Campo: E-Mail campo creato' },

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
    label: 'Camp: E-Mail responsable de groupe assigné' },

  { custom_content_id: camp_al_assigned_id,
    locale: 'en',
    label: 'Camp: Email group officer assigned' },

  { custom_content_id: camp_al_assigned_id,
    locale: 'it',
    label: 'Campo: E-Mail Capo sezione assegnato' },

  { custom_content_id: camp_submit_reminder_id,
    locale: 'de',
    label: 'Lager: E-Mail Lager einreichen Erinnerung',
    subject: 'Lager: Lager einreichen Erinnerung',
    body: '{recipient-name-with-salutation}<br><br>' \
          'Das Lager "{camp-name}" muss noch an PBS eingereicht werden:<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_submit_reminder_id,
    locale: 'fr',
    label: 'Camp: E-Mail évoquer déposer de camp' },

  { custom_content_id: camp_submit_reminder_id,
    locale: 'en',
    label: 'Camp: Email submit camp reminder' },

  { custom_content_id: camp_submit_reminder_id,
    locale: 'it',
    label: 'Campo: E-Mail promemoria presentare campo' },

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
    label: 'Camp: E-Mail déposer de camp' },

  { custom_content_id: camp_submit_id,
    locale: 'en',
    label: 'Camp: Email camp submit' },

  { custom_content_id: camp_submit_id,
    locale: 'it',
    label: 'Campo: E-Mail presentare campo' },

  { custom_content_id: camp_participant_applied_id,
    locale: 'de',
    label: 'Lager: E-Mail Teilnehmer-/in hat sich angemeldet',
    subject: 'Lager: Teilnehmer-/in hat sich angemeldet',
    body: 'Hallo<br><br>' \
          '{participant-name} hat sich für das Lager "{camp-name}" angemeldet:<br><br>' \
          '{camp-url}<br>' },

  { custom_content_id: camp_participant_applied_id,
    locale: 'fr',
    label: 'Camp: E-Mail Participant/-e a enregistré' },

  { custom_content_id: camp_participant_applied_id,
    locale: 'en',
    label: 'Camp: E-Mail Participant has applied' },

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
    label: 'Camp: E-Mail Participant/-e a disputer' },

  { custom_content_id: camp_participant_canceled_id,
    locale: 'en',
    label: 'Camp: Email Participant has unsubscribed'},

  { custom_content_id: camp_participant_canceled_id,
    locale: 'it',
    label: 'Campo: E-Mail Participante ha annullare' },

  { custom_content_id: black_list_hit_id,
    locale: 'de',
    label: 'Schwarze Liste: E-Mail Treffer',
    subject: 'Treffer auf Schwarzer Liste',
    body: 'Die Person {black-list-person} wurde bei {joined-target} hinzugefügt.' \
          '<br><br>Möglicherweise befindet sich diese Person auf der schwarzen Liste. ' \
          'Bitte prüfen und gegebenenfalls auf die Gruppe oder einen Referenzkontakt zugehen.' \
          '<br><br>Diese Nachricht wurde automatisch aus der MiData verschickt.'},

  { custom_content_id: black_list_hit_id,
    locale: 'fr',
    label: 'liste noire: E-Mail hit sur la liste noire' },

  { custom_content_id: black_list_hit_id,
    locale: 'en',
    label: 'black list: E-Mail hit on black list'},

  { custom_content_id: black_list_hit_id,
    locale: 'it',
    label: 'lista nera: E-Mail hit su lista nera' },

  { custom_content_id: black_list_attr_hit_id,
    locale: 'de',
    label: 'Schwarze Liste: E-Mail Treffer',
    subject: 'Treffer auf Schwarzer Liste',
    body: 'Die Person {black-list-person} wurde aktualisiert.' \
          '<br><br>Möglicherweise befindet sich diese Person auf der schwarzen Liste. ' \
          'Bitte prüfen und gegebenenfalls auf die Gruppe oder einen Referenzkontakt zugehen.' \
          '<br><br>Diese Nachricht wurde automatisch aus der MiData verschickt.'},

  { custom_content_id: black_list_attr_hit_id,
    locale: 'fr',
    label: 'liste noire: E-Mail hit sur la liste noire' },

  { custom_content_id: black_list_attr_hit_id,
    locale: 'en',
    label: 'black list: E-Mail hit on black list'},

  { custom_content_id: black_list_attr_hit_id,
    locale: 'it',
    label: 'lista nera: E-Mail hit su lista nera' },

  { custom_content_id: crisis_triggered_id,
    locale: 'de',
    label: 'Verantwortliche über Einleitung einer Krise informieren',
    subject: 'Krise wurde eingeleitet',
    body: '{creator} hat am {date} eine Krise in der Gruppe {group} eingeleitet.' },

  { custom_content_id: crisis_triggered_id,
    locale: 'fr',
    label: 'Informer les responsables de la crise déclenchée' },

  { custom_content_id: crisis_triggered_id,
    locale: 'en',
    label: 'Inform responsibles about triggered crisis' },

  { custom_content_id: crisis_triggered_id,
    locale: 'it',
    label: 'Informare i responsabili della crisi innescata' },

  { custom_content_id: crisis_acknowledged_id,
    locale: 'de',
    label: 'Verantwortliche über Quittierung einer Krise informieren',
    subject: 'Krise wurde quittiert',
    body: 'Die von {creator} am {date} in der Gruppe {group} eingeleitet Krise '\
          'wurde von {acknowledger} quittiert.'},

  { custom_content_id: crisis_acknowledged_id,
    locale: 'fr',
    label: 'Crise: E-Mail Informer la personne responsable de la reconnaissance' },

  { custom_content_id: crisis_acknowledged_id,
    locale: 'en',
    label: 'Crisis: E-Mail Inform the responsibles about acknowledgement' },

  { custom_content_id: crisis_acknowledged_id,
    locale: 'it',
    label: 'Crisi: E-Mail Informare la persona responsabile riguardo al riconoscimento' },

  { custom_content_id: course_confirmation_id,
    locale: 'de',
    label: 'Kursbestätigung: Qualifizierte/n Teilnehmer/in informieren',
    subject: 'Kursbestätigung verfügbar',
    body: '{recipient-name-with-salutation}<br><br>'\
          'Für den bestandenen Kurs "{course-name}" '\
          'kann jetzt hier eine Bestätigung ausgedruckt werden:<br><br>{participation-url}<br>'},

  { custom_content_id: course_confirmation_id,
    locale: 'fr',
    label: 'Confirmation de cours: Informer participant/e' },

  { custom_content_id: course_confirmation_id,
    locale: 'en',
    label: 'Course confirmation: Inform participant' },

  { custom_content_id: course_confirmation_id,
    locale: 'it',
    label: 'Confirmazione del corso: Informare participante' },

  { custom_content_id: groupfinder_fields_info_id,
   locale: 'de',
   label: 'Pfadi-Finder: Infotext für Felder auf Abteilung',
   body: 'In den folgenden Feldern könnt ihr die öffentlichen Angaben eurer Abteilung eintragen. ' \
         'Diese Angaben werden jeweils nächtlich in den Pfadi-Finder unter https://pfadi.swiss übernommen. ' \
         'Es können bis zu {max-number-of-geolocations} Treffpunkte pro Abteilung definiert werden.'},

  { custom_content_id: groupfinder_fields_info_id,
   locale: 'fr',
   label: 'Trouveur des groupes de scout: Texte d\'informations sur donnees de groupe' },

  { custom_content_id: groupfinder_fields_info_id,
   locale: 'en',
   label: 'Scout group finder: Informational text for the fields on group'},

  { custom_content_id: groupfinder_fields_info_id,
   locale: 'it',
   label: 'Trovatore delle sezioni scout: Testo d\'informazioni su dati della sezione' },

)

[Event::Course, Event::Camp, Event::Campy].each do |event_type|
  self_key = [Pbs::Event::ParticipationsController::CONTENT_KEY_JS_DATA_SHARING_INFO_SELF, event_type&.name].compact.join('-')
  other_key = [Pbs::Event::ParticipationsController::CONTENT_KEY_JS_DATA_SHARING_INFO_OTHER, event_type&.name].compact.join('-')

  CustomContent.seed_once(:key,
    { key: self_key },
    { key: other_key }
  )

  self_id = CustomContent.get(self_key).id
  other_id = CustomContent.get(other_key).id

  event_type_label_de = "Anlass (#{event_type.name.demodulize})"
  event_type_label_fr = "Événement (#{event_type.name.demodulize})"
  event_type_label_it = "Evento (#{event_type.name.demodulize})"
  event_type_label_en = "Event (#{event_type.name.demodulize})"

  CustomContent::Translation.seed_once(:custom_content_id, :locale,
    { custom_content_id: self_id,
      locale: 'de',
      label: "#{event_type_label_de} Anmeldung: Einverständnis zur Datenweitergabe",
      subject: 'Einverständnis zur Datenweitergabe',
      body: 'Ich bin mit der Weitergabe meiner Daten an J+S wie im Merkblatt "XY" beschrieben einverstanden'},

    { custom_content_id: self_id, locale: 'fr', label: "#{event_type_label_fr} inscription : consentement au transfert de données" },
    { custom_content_id: self_id, locale: 'it', label: "#{event_type_label_it} registrazione: consenso al trasferimento dei dati" },
    { custom_content_id: self_id, locale: 'en', label: "#{event_type_label_en} registration: consent to data transfer" },

    { custom_content_id: other_id,
      locale: 'de',
      label: "#{event_type_label_de} Fremdanmeldung: Einverständnis zur Datenweitergabe",
      subject: 'Einverständnis zur Datenweitergabe',
      body: 'Die angemeldete Persion ist mit der Weitergabe ihrer Daten an J+S wie im Merkblatt "XY" beschrieben einverstanden'},

    { custom_content_id: other_id, locale: 'fr', label: "#{event_type_label_fr} enregistrement de tiers : consentement au transfert de données" },
    { custom_content_id: other_id, locale: 'it', label: "#{event_type_label_it} registrazione di terze parti : consenso al trasferimento dei dati" },
    { custom_content_id: other_id, locale: 'en', label: "#{event_type_label_en} third-party registration: consent to data transfer" }
  )
end
