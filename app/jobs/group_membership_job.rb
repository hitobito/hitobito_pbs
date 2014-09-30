# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class GroupMembershipJob < BaseJob

  self.parameters = [:recipient_id, :actuator_id, :group_id, :locale]

  def initialize(recipient, actuator, group)
    super()
    @recipient_id = recipient.id
    @actuator_id = actuator.id
    @group_id = group.id
  end

  def perform
    set_locale
    if recipient.email?
      GroupMembershipMailer.added_to_group(recipient, actuator, group).deliver
    end
  end

  def recipient
    @recipient ||= Person.find(@recipient_id)
  end

  def actuator
    @actuator ||= Person.find(@actuator_id)
  end

  def group
    @group ||= Group.find(@group_id)
  end
end
