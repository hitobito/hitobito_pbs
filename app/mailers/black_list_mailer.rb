#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class BlackListMailer < ApplicationMailer
  CONTENT_BLACK_LIST_HIT = "black_list_hit".freeze
  CONTENT_BLACK_LIST_ATTR_HIT = "black_list_attr_hit".freeze
  BLACK_LIST_ROLES = [Group::Bund::Geschaeftsleitung,
    Group::Bund::LeitungKernaufgabeKommunikation].freeze

  def hit(person, target = nil)
    return if recipients.blank?

    @person = person
    @target = target

    key = target ? CONTENT_BLACK_LIST_HIT : CONTENT_BLACK_LIST_ATTR_HIT
    custom_content_mail(recipients, key, values_for_placeholders(key))
  end

  private

  def recipients
    @recipients ||= Person
      .joins(:roles)
      .where(roles: {type: BLACK_LIST_ROLES.map(&:sti_name)})
      .pluck(:email)
  end

  def placeholder_black_list_person
    url = person_url(@person)
    link_to(@person.full_name, url)
  end

  def placeholder_joined_target
    link_to(@target, polymorphic_url(@target)) if @target
  end
end
