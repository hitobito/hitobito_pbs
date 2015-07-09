# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::ApprovalRequestJob < BaseJob

  self.parameters = [:layer_name, :participation_id, :locale]

  def initialize(layer_name, participation)
    super()
    @layer_name = layer_name
    @participation_id = participation.id
  end

  def perform
    return unless participation # may have been deleted again

    set_locale
    send_approval
  end

  def send_approval
    if participation.event.send("requires_approval_#{@layer_name}?")
      recipients = approvers
      if recipients.exists?
        Event::ParticipationMailer.approval(participation, recipients).deliver
      end
    end
  end

  def approvers
    approver_group_ids = primary_group.hierarchy.where(type: layer_type.sti_name).pluck(:id)
    approver_types = layer_type.role_types.select do |role_type|
      role_type.permissions.include?(:approve_applications)
    end

    Person.only_public_data.
           joins(roles: :group).
           where(roles: { type: approver_types, deleted_at: nil },
                 groups: { id: approver_group_ids }).
           uniq
  end

  def participation
    @participation ||= Event::Participation.find(@participation_id)
  end

  def primary_group
    @primary_group ||= participation.person.primary_group
  end

  def layer_type
    @layer_type ||= "Group::#{@layer_name.classify}".constantize
  end
end
