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

  def approve(comment, user)
    return unless primary_group

    update_approval(true, comment, user)

    next_layer_name = next_approval_layer
    if next_layer_name
      request_approval(next_layer_name)
    else
      application.update!(approved: true)
    end
  end

  def reject(comment, user)
    update_approval(false, comment, user)
    application.update!(rejected: true)
  end

  def open_approval
    @open_approval ||= application.approvals.find_by(approved: false, rejected: false)
  end

  def current_approvers
    if open_approval && primary_group
      approvers_for_layer(open_approval.layer)
    else
      Person.none
    end
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

  def update_approval(approved, comment, user)
    attr = approved ? :approved : :rejected
    open_approval.update!(attr => true,
                          comment: comment,
                          approver: user,
                          approved_at: Time.zone.now)
  end

  def approvers_for_layer(layer_name)
    groups = hierarchy.select { |g| g.class.name.demodulize.downcase == layer_name }
    return Person.none if groups.blank?

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
