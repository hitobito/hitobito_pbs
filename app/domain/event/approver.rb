# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Contains all the business logic for the approval process.
class Event::Approver

  attr_reader :participation, :application, :primary_group, :open_approval

  def initialize(participation)
    @participation = participation
    @primary_group = participation.person.primary_group
    @application = participation.application
    @open_approval = find_next_open_approval if application
  end

  def application_created
    layer = first_layer_requiring_approval
    if layer.present? && application.present?
      approval = application.approvals.create!(layer: name_of_layer(layer))
      send_approval_request(layer, approval)
    end
  end

  # rubocop:disable all
  # gemäss 4.103, 4.108
  # find Event::Approval for given layer
  # update fields
  # if no next layer, set application#approved to true and return
  # create Event::Approval for next layer from which approval is required (and which has existing :approve_applications roles)
  # send email to all roles from affected layer(s) with permission :approve_applications
  def approve(comment, user)
    return unless primary_group.present?
    open_approval.update!(approved: true, comment: comment, approver: user, approved_at: Time.zone.now)
    _first, *rest = primary_group.layer_hierarchy.reverse.drop_while { |g| open_approval.layer_class != g.class }

    if rest.empty? || !find_next_approving_layer(rest.first)
      application.update!(approved: true)
    else
      layer = find_next_approving_layer(rest.first)
      approval = application.approvals.create!(layer: name_of_layer(layer))
      send_approval_request(layer, approval)
    end
  end

  # gemäss 4.1010
  # find Event::Approval for given layer
  # update fields
  # set application#rejected to true
  def reject(comment, user)
    open_approval.update!(rejected: true, comment: comment, approver: user, approved_at: Time.zone.now)
    participation.application.update!(rejected: true)
    #TODO: send_mail_to_rejecter(user)
  end
  # rubocop:enable all

  private

  def first_layer_requiring_approval
    return unless primary_group.present?

    find_next_approving_layer(primary_group)
  end

  def find_next_open_approval
    application.approvals.find_by(approved: false, rejected: false)
  end

  def find_next_approving_layer(group)
    group.layer_hierarchy.reverse.find do |g|
      event_requires_approval_from?(name_of_layer(g)) && group_has_approvers?(g)
    end
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

  def name_of_layer(group)
    group.layer_group.class.name.demodulize.downcase
  end

  def send_approval_request(layer, approval)
    Event::ApprovalRequestJob.new(name_of_layer(layer), approval.participation).enqueue!
  end

end
