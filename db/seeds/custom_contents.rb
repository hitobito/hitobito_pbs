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

)

group_membership_id = CustomContent.where(key: GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP).first.id
participation_confirmation_other_id = CustomContent.get(Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER).id

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
)

