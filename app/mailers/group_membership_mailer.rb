# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class GroupMembershipMailer < ApplicationMailer

  CONTENT_GROUP_MEMBERSHIP = 'group_membership'.freeze

  def added_to_group(recipient, actuator, group)
    @recipient = recipient
    @actuator = actuator
    @group = group

    # This email is only sent to the main email address.
    custom_content_mail(recipient.email,
                        CONTENT_GROUP_MEMBERSHIP,
                        values_for_placeholders(CONTENT_GROUP_MEMBERSHIP))
  end

  private

  def placeholder_recipient_name
    @recipient.greeting_name
  end

  def placeholder_recipient_name_with_salutation
    @recipient.salutation_value
  end

  def placeholder_actuator_name
    @actuator.to_s
  end

  def placeholder_group_link
    group_links = @group.with_layer.map do |g|
      link_to(g, group_url(g))
    end
    group_links.join(' / ')
  end

end
