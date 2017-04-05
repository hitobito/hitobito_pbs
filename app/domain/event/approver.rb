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
    return unless primary_group && application

    layer_name = next_approval_layer
    if layer_name
      request_approval(layer_name)
    end
  end

  def approve(attrs, user)
    return unless primary_group

    if update_approval(true, attrs, user)
      next_layer_name = next_approval_layer
      if next_layer_name
        request_approval(next_layer_name)
      else
        application.update!(approved: true)
      end
      true
    end
  end

  def reject(attrs, user)
    update_approval(false, attrs, user) &&
      application.update!(rejected: true)
  end

  def open_approval
    @open_approval ||= application.approvals.find_by(approved: false, rejected: false)
  end

  def current_approvers
    people = []
    if open_approval && primary_group
      groups = groups_of_layer(open_approval.layer)
      if groups.present?
        people = approvers_for_groups_with_role(groups)
      end
    end
    people
  end

  private

  def next_approval_layer
    unapproved_layers.find do |layer_name|
      event_requires_approval_from?(layer_name) &&
        approvers_for_layer(layer_name).exists?
    end
  end

  def unapproved_layers
    if open_approval
      approved_to = Event::Approval::LAYERS.find_index(open_approval.layer) + 1
      Event::Approval::LAYERS[approved_to..-1]
    else
      Event::Approval::LAYERS
    end
  end

  def request_approval(layer_name)
    application.approvals.create!(layer: layer_name)
    send_approval_request
  end

  def update_approval(approved, attrs, user)
    attr = approved ? :approved : :rejected
    open_approval.update({ attr => true,
                           approver: user,
                           approved_at: Time.zone.now }.merge(attrs))
  end

  def approvers_for_layer(layer_name)
    groups = groups_of_layer(layer_name)
    if groups.present?
      approvers_for_groups(groups)
    else
      Person.none
    end
  end

  def groups_of_layer(layer_name)
    hierarchy.select { |g| g.class.name.demodulize.downcase == layer_name }
  end

  def approvers_for_groups(groups)
    role_types = approver_role_types_of(groups.first.class)
    Person.joins(:roles).
      where(roles: { group_id: groups.collect(&:id),
                     type: role_types.collect(&:sti_name),
                     deleted_at: nil }).
      uniq
  end

  def approver_role_types_of(layer_type)
    layer_type.role_types.select do |role_type|
      role_type.permissions.include?(:approve_applications)
    end
  end

  def approvers_for_groups_with_role(groups)
    approvers = approvers_for_groups(groups).only_public_data.includes(:roles).to_a
    groups.collect do |group|
      group_role_approvers(group, approvers).presence ||
        group_all_approvers(group, approvers)
    end.flatten.uniq
  end

  def group_role_approvers(group, people)
    people.select do |person|
      person.roles.any? do |role|
        role.group_id == group.id && role.class.name == group.application_approver_role
      end
    end
  end

  def group_all_approvers(group, people)
    people.select do |person|
      person.roles.any? do |role|
        role.group_id == group.id && role.permissions.include?(:approve_applications)
      end
    end
  end

  def hierarchy
    @hierarchy ||= primary_group.layer_hierarchy.reverse
  end

  def application
    participation.application
  end

  def primary_group
    participation.person.primary_group
  end

  def event_requires_approval_from?(layer_name)
    participation.event.send("requires_approval_#{layer_name}?")
  end

  def send_approval_request
    Event::ApprovalRequestJob.new(participation).enqueue!
  end

end
