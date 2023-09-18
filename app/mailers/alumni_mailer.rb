# encoding: utf-8

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AlumniMailer < ApplicationMailer

  CONTENT_INVITATION_WITH_REGIONAL_GROUPS = 'alumni_invitation_with_regional_alumni_groups'
  CONTENT_INVITATION_WITHOUT_REGIONAL_GROUPS = 'alumni_invitation_without_regional_alumni_groups'

  CONTENT_REMINDER_WITH_REGIONAL_GROUPS = 'alumni_reminder_with_regional_alumni_groups'
  CONTENT_REMINDER_WITHOUT_REGIONAL_GROUPS = 'alumni_reminder_without_regional_alumni_groups'

  def invitation(person, alumni_groups, silverscout_groups)
    @person = person
    @alumni_groups = alumni_groups
    @silverscout_groups = silverscout_groups

    key = @silverscout_groups.present? ?
      CONTENT_INVITATION_WITH_REGIONAL_GROUPS :
      CONTENT_INVITATION_WITHOUT_REGIONAL_GROUPS

    custom_content_mail(@person.email, key, values_for_placeholders(key))
  end

  def reminder(person, alumni_groups, silverscout_groups)
    @person = person
    @alumni_groups = alumni_groups
    @silverscout_groups = silverscout_groups

    key = @silverscout_groups.present? ?
      CONTENT_REMINDER_WITH_REGIONAL_GROUPS :
      CONTENT_REMINDER_WITHOUT_REGIONAL_GROUPS

    custom_content_mail(@person.email, key, values_for_placeholders(key))
  end

  private

  # Placeholder {person-name}
  def placeholder_person_name
    @person.full_name
  end

  # Placeholder {SiScRegion-Links}
  def placeholder_si_sc_region_links
    group_selfinscription_links(@silverscout_groups)
  end

  # Placeholder {AlumniGroup-Links}
  def placeholder_alumni_group_links
    group_selfinscription_links(@alumni_groups)
  end

  def group_selfinscription_links(groups)
    view_helpers.content_tag(:ul) do
      groups.each_with_object("") do |group, links|
        url = url_helpers.self_inscription_groups_url(group)
        group_link = view_helpers.link_to(group.name, url)
        links << content_tag(:li, group_link)
      end
    end
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def view_helpers
    ActionController::Base.helpers
  end
end
