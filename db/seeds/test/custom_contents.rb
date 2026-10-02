# frozen_string_literal: true

#  Copyright (c) 2017-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/No such property: ProjectRootManager for class: Script1

# update these contents from hitobito-core, always, to supersede (haha) the seeds from
# hitobito-core: the PBS salutation mailers need the additional *-with-salutation placeholders.
# On production this cannot be done with seeds — CustomContent.seed would reset the
# placeholders on every wagon:seed run and discard any placeholders_required/optional
# customized in the admin UI. The migration AddSalutationPlaceholdersToCustomContents
# (db/migrate/20170315152342_add_salutation_placeholders_to_custom_contents.rb) therefore
# patched the existing records once, after the core seeds had created them.
# In the test database these seeds are the only way to reach that same state: the migration's
# changes are wiped when all tables are truncated in the before(:suite) hook, and the core
# seeds would restore the core placeholder lists. This file lives in db/seeds/test, which the
# wagon only seeds when Rails.env == test (see Wagons::Wagon#seed_fixtures), so it never runs
# on production.
CustomContent.seed(:key,
  { key: Person::LoginMailer::CONTENT_LOGIN,
    placeholders_required: 'login-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, sender-name' },

  { key: Event::ParticipationMailer::CONTENT_CONFIRMATION,
    placeholders_required: 'event-details, application-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name' },

  { key: Event::ParticipationMailer::CONTENT_APPROVAL,
    placeholders_required: 'participant-name, event-details, application-url',
    placeholders_optional: 'recipient-names-with-salutation, recipient-names' },

  { key: Event::ParticipationMailer::CONTENT_CANCEL,
    placeholders_required: 'event-details',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name' },

  { key: Event::RegisterMailer::CONTENT_REGISTER_LOGIN,
    placeholders_required: 'event-url',
    placeholders_optional: 'recipient-name-with-salutation, recipient-name, event-name' },

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_PERSON,
    placeholders_required: 'request-body, answer-request-url',
    placeholders_optional:
      'recipient-name-with-salutation, recipient-name, requester-name, requester-roles' },

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_RESPONSIBLES,
    placeholders_required: 'person-name, request-body, answer-request-url',
    placeholders_optional:
      'recipient-names-with-salutation, recipient-names, requester-name, requester-roles' },

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_APPROVED,
    placeholders_required: 'person-name, request-body',
    placeholders_optional:
      'recipient-name-with-salutation, recipient-name, approver-name, approver-roles' },

  { key: Person::AddRequestMailer::CONTENT_ADD_REQUEST_REJECTED,
    placeholders_required: 'person-name, request-body',
    placeholders_optional:
      'recipient-name-with-salutation, recipient-name, rejecter-name, rejecter-roles' }
)
