# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AlumniMailer < ApplicationMailer

  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include Rails.application.routes.url_helpers

  CONTENT_INVITATION_WITH_REGIONAL_GROUPS = 'alumni_invitation_with_regional_alumni_groups'
  CONTENT_INVITATION_WITHOUT_REGIONAL_GROUPS = 'alumni_invitation_without_regional_alumni_groups'

  CONTENT_REMINDER_WITH_REGIONAL_GROUPS = 'alumni_reminder_with_regional_alumni_groups'
  CONTENT_REMINDER_WITHOUT_REGIONAL_GROUPS = 'alumni_reminder_without_regional_alumni_groups'

  def invitation(person, ex_members_groups, silverscout_groups)
    @person = person
    @ex_members_groups = ex_members_groups
    @silverscout_groups = silverscout_groups

    key = if @ex_members_groups.present?
            CONTENT_INVITATION_WITH_REGIONAL_GROUPS
          else
            CONTENT_INVITATION_WITHOUT_REGIONAL_GROUPS
          end

    custom_content_mail(@person.email, key, values_for_placeholders(key))
  end

  def reminder(person, ex_members_groups, silverscout_groups)
    @person = person
    @ex_members_groups = ex_members_groups
    @silverscout_groups = silverscout_groups

    key = if @ex_members_groups.present?
            CONTENT_REMINDER_WITH_REGIONAL_GROUPS
          else
            CONTENT_REMINDER_WITHOUT_REGIONAL_GROUPS
          end

    custom_content_mail(@person.email, key, values_for_placeholders(key))
  end

  private

  # Placeholder {person-name}
  def placeholder_person_name
    @person.full_name
  end

  # Placeholder {SiScRegion-Links}
  def placeholder_si_sc_region_links
    format_helper.group_selfinscription_links(@silverscout_groups, &:name)
  end

  # Placeholder {AlumniGroup-Links}
  def placeholder_alumni_group_links
    format_helper.group_selfinscription_links(@ex_members_groups) do |group|
      "#{group.parent.name}: #{group.name}"
    end
  end

  def format_helper
    @format_helper ||= AlumniMailer::FormatHelper.new(default_url_options)
  end
end
