# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Contains all the business logic for the approval process.
class Event::Approver

  attr_reader :participation, :application, :primary_group, :open_approval, :hierarchy

  def initialize(participation)
    @participation = participation
    @primary_group = participation.person.primary_group
    @application = participation.application
    @open_approval = find_current_open_approval if application
  end

  def application_created
    return unless primary_group && application

    layer_name = approval_layers.first
    approval = application.approvals.create!(layer: layer_name)
    send_approval_request(layer_name, approval)
  end

  def approve(comment, user)
    return unless primary_group
      open_approval.update!(approved: true, comment: comment, approver: user, approved_at: Time.zone.now)
      next_layer_name = approval_layers.drop_while { |layer| layer != open_approval.layer }.second

      if next_layer_name
        approval = application.approvals.create!(layer: next_layer_name)
        send_approval_request(next_layer_name, approval)
      else
        application.update!(approved: true)
      end
  end

  def reject(comment, user)
    open_approval.update!(rejected: true, comment: comment, approver: user, approved_at: Time.zone.now)
    participation.application.update!(rejected: true)
  end

  private

  def approval_layers
    @approval_layers ||= find_approval_layers
  end

  def find_approval_layers
    Event::Approval::LAYERS.select do |layer_name|
      event_requires_approval_from?(layer_name) &&
        hierarchy_has_layer_with_approvers?(layer_name)
    end
  end

  def hierarchy_has_layer_with_approvers?(layer_name)
    hierarchy.any? { |g| g.layer_group.class.name.demodulize.downcase == layer_name &&  group_has_approvers?(g) }
  end

  def hierarchy
    @hierarchy ||= primary_group.layer_hierarchy.reverse
  end

  def find_current_open_approval
    application.approvals.find_by(approved: false, rejected: false)
  end

  def event_requires_approval_from?(layer_name)
    participation.event.send("requires_approval_#{layer_name}?")
  end

  def group_has_approvers?(group)
    approvers_of_group(group).exists?
  end

  def approvers_of_group(group)
    role_types = approver_role_types_of(group.layer_group.class)
    group.people.where(roles: { type: role_types.collect(&:sti_name), deleted_at: nil })
  end

  def approver_role_types_of(layer_type)
    layer_type.role_types.select do |role_type|
      role_type.permissions.include?(:approve_applications)
    end
  end

  def send_approval_request(layer_name, approval)
    Event::ApprovalRequestJob.new(layer_name, approval.participation).enqueue!
  end

end
