# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class GroupMembershipMailer < ApplicationMailer

  CONTENT_GROUP_MEMBERSHIP = 'group_membership'

  def added_to_group(recipient, actuator, group)
    values = {
      'recipient-name'                 => recipient.greeting_name,
      'recipient-name-with-salutation' => recipient.salutation_value,
      'actuator-name'                  => actuator.to_s,
      'group-link'                     => group_link_with_layer(group)
    }

    # This email is only sent to the main email address.
    custom_content_mail(recipient.email, CONTENT_GROUP_MEMBERSHIP, values)
  end

  private

  def group_link_with_layer(group)
    group_links = group.with_layer.map do |g|
      link_to(g, group_url(g))
    end
    group_links.join(' / ')
  end

end
