#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::Course::ConfirmationMailer < ApplicationMailer
  CONTENT_COURSE_CONFIRMATION = "course_confirmation".freeze

  attr_reader :participation

  def notify(participation)
    @participation = participation
    compose(participation.person, CONTENT_COURSE_CONFIRMATION)
  end

  private

  def placeholder_recipient_name_with_salutation
    participation.person.salutation_value
  end

  def placeholder_recipient_name
    participation.person.greeting_name
  end

  def placeholder_course_name
    participation.event.name
  end

  def placeholder_participation_url
    link_to(group_event_participation_url(participation.event.groups.first, participation.event,
      participation))
  end
end
