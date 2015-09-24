# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationMailer
  extend ActiveSupport::Concern

  CONTENT_CONFIRMATION_OTHER = 'event_application_confirmation_other'

  CONTENT_CANCELED_PARTICIPATION = 'event_participation_canceled'

  CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST =
    'event_participation_assigned_from_waiting_list'

  CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST =
    'event_participation_removed_from_waiting_list'

  def confirmation_other(participation)
    @participation = participation

    filename = Export::Pdf::Participation.filename(participation)
    attachments[filename] = Export::Pdf::Participation.render(participation)
    compose(CONTENT_CONFIRMATION_OTHER,
            person,
            'recipient-name' => person.greeting_name)
  end

  def canceled(participation, recipients)
    @participation = participation

    compose(CONTENT_CANCELED_PARTICIPATION,
            recipients,
            'canceled-at' => I18n.l(participation.canceled_at),
            'event-name' => event.to_s,
            'participant-name' => person.to_s)
  end

  def removed_from_waiting_list(participation, setter, current_user)
    @participation = participation

    compose(CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST,
            setter,
            'waiting-list-setter' => setter.greeting_name,
            'event-name' => event.to_s,
            'leader-name' => current_user.to_s,
            'participant-name' => person.to_s)
  end

  def assigned_from_waiting_list(participation, setter, current_user)
    @participation = participation

    compose(CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST,
            setter,
            'waiting-list-setter' => setter.greeting_name,
            'event-name' => event.to_s,
            'leader-name' => current_user.to_s,
            'participant-name' => person.to_s)
  end

end
