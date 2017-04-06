# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationMailer
  extend ActiveSupport::Concern

  CONTENT_CONFIRMATION_OTHER = 'event_application_confirmation_other'.freeze

  CONTENT_CANCELED_PARTICIPATION = 'event_participation_canceled'.freeze

  CONTENT_REJECTED_PARTICIPATION = 'event_participation_rejected'.freeze

  CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST =
    'event_participation_assigned_from_waiting_list'.freeze

  CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST =
    'event_participation_removed_from_waiting_list'.freeze

  def confirmation_other(participation)
    @participation = participation

    filename = Export::Pdf::Participation.filename(participation)
    attachments[filename] = Export::Pdf::Participation.render(participation)
    compose(person, CONTENT_CONFIRMATION_OTHER)
  end

  def canceled(participation, recipients)
    @participation = participation

    compose(recipients, CONTENT_CANCELED_PARTICIPATION)
  end

  def rejected(participation, recipients)
    @participation = participation

    compose(recipients, CONTENT_REJECTED_PARTICIPATION)
  end

  def removed_from_waiting_list(participation, setter, current_user)
    @participation = participation
    @setter = setter
    @current_user = current_user

    compose(setter, CONTENT_PARTICIPATION_REMOVED_FROM_WAITING_LIST)
  end

  def assigned_from_waiting_list(participation, setter, current_user)
    @participation = participation
    @setter = setter
    @current_user = current_user

    compose(setter, CONTENT_PARTICIPATION_ASSIGNED_FROM_WAITING_LIST)
  end

  private

  def placeholder_canceled_at
    I18n.l(participation.canceled_at)
  end

  def placeholder_event_name
    event.to_s
  end

  def placeholder_leader_name
    @current_user.to_s
  end

  def placeholder_recipient_name_with_salutation
    person.salutation_value
  end

  def placeholder_recipient_names_with_salutation
    @recipients.map(&:salutation_value).join(', ')
  end

  def placeholder_waiting_list_setter
    @setter.greeting_name
  end

end
