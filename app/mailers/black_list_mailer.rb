#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class BlackListMailer < ApplicationMailer

  CONTENT_BLACK_LIST_HIT = 'black_list_hit'.freeze
  BLACK_LIST_ROLES = [ Group::Bund::Geschaeftsleitung,
                       Group::Bund::LeitungKernaufgabeKommunikation ].freeze

  def group_hit(person, group)
    @group = group
    hit(person)
  end

  def event_hit(person, event)
    @event = event
    hit(person)
  end

  private

  def hit(person)
    return if recipients.blank?

    @person = person
    custom_content_mail(recipients,
                        CONTENT_BLACK_LIST_HIT,
                        values_for_placeholders(CONTENT_BLACK_LIST_HIT))
  end

  def recipients
    @recipients ||= Person.
                      joins(:roles).
                      where('roles.type IN (?)', BLACK_LIST_ROLES).
                      pluck(:email)
  end

  def placeholder_black_list_person
    url = person_url(@person)
    link_to(@person.full_name, url)
  end

  def placeholder_joined_target
    if @group
      link_to(@group, group_url(@group))
    else
      link_to(@event, event_url(@event))
    end
  end
end
