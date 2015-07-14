# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationMailer
  extend ActiveSupport::Concern

  CONTENT_CONFIRMATION_OTHER = 'event_application_confirmation_other'

  def confirmation_other(participation)
    @participation = participation

    filename = Export::Pdf::Participation.filename(participation)
    attachments[filename] = Export::Pdf::Participation.render(participation)
    compose(CONTENT_CONFIRMATION_OTHER,
            [person],
            'recipient-name' => person.greeting_name)
  end

end
