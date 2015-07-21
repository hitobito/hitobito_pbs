# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationMailer
  extend ActiveSupport::Concern

  CONTENT_CONFIRMATION_OTHER = 'event_application_confirmation_other'

  CONTENT_CANCELED_PARTICIPATION = 'event_participation_canceled'

  def confirmation_other(participation)
    @participation = participation

    filename = Export::Pdf::Participation.filename(participation)
    attachments[filename] = Export::Pdf::Participation.render(participation)
    compose(CONTENT_CONFIRMATION_OTHER,
            [person],
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

end
