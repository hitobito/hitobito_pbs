# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

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

