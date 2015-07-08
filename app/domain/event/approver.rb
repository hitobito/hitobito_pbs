# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Contains all the business logic for the approval process.
class Event::Approver

  attr_reader :participation

  def initialize(participation)
    @participation = participation
  end

  def application_created
    layer = first_layer_requiring_approval
    if layer.present?
      participation.application.approvals.create!(layer: layer)
      send_mail_to_approvers(layer)
    end
  end

  # rubocop:disable all
  def approve(_layer, _comment, _user)
    # gemäss 4.103, 4.108
    # find Event::Approval for given layer
    # update fields
    # if no next layer, set application#approved to true and return
    # create Event::Approval for next layer from which approval is required (and which has existing :approve_applications roles)
    # send email to all roles from affected layer(s) with permission :approve_applications
  end

  def reject(_layer, _comment, _user)
    # gemäss 4.1010
    # find Event::Approval for given layer
    # update fields
    # set application#rejected to true
  end
  # rubocop:enable all

  private

  def first_layer_requiring_approval
    primary_group = participation.person.primary_group
    if primary_group
      primary_group.layer_hierarchy.reverse.each do |group|
        if group_requires_approval?(group) && group_has_approvers?(group)
          return group.class.name.demodulize.downcase
        end
      end

      nil
    end
  end

  def group_requires_approval?(group)
    if group.present?
      group_type_name = group.class.name.demodulize.downcase
      participation.event.send("requires_approval_#{group_type_name}?")
    else
      false
    end
  end

  def group_has_approvers?(group)
    approvers_of_group(group).try('exists?')
  end

  def approvers_of_group(group)
    if group.present?
      role_types = approver_role_types_of_group(group)
      group.people.where('roles.type IN (?)', role_types.collect(&:sti_name))
    end
  end

  def approver_role_types_of_group(group)
    group.present? && group.role_types.select do |role_type|
      role_type.permissions.include?(:approve_applications)
    end
  end

  # rubocop:disable all
  def send_mail_to_approvers(group)
    # TODO
  end
  # rubocop:enable all

end
