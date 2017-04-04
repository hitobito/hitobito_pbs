# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Group::PendingApprovalsController < ApplicationController

  decorates :group

  before_action :authorize_action

  helper_method :course_kind_id

  def index
    load_pending_approvals
    @approver_roles = approver_roles
    load_approved_course_kinds
    load_approved_approvals
  end

  def approved
    load_approved_course_kinds
    load_approved_approvals
  end

  def update_role
    role = params[:approver_role]
    role = nil unless approver_roles.collect(&:name).include?(role)
    group.update_column(:application_approver_role, role)
    head :ok
  end

  private

  def group
    @group ||= Group.find(params[:id])
  end

  def load_pending_approvals
    @pending_approvals =
      Event::Approval.pending(group).
      includes(:participation, :approvee, event: :groups).
      order('event_participations.created_at ASC')
  end

  def approver_roles
    group.class.role_types.select { |t| t.permissions.include?(:approve_applications) }
  end

  def load_approved_approvals
    @approved_approvals ||=
      approved_approvals.where(course_kind_id.present? && ['events.kind_id = ?', course_kind_id])
                        .order(approved_at: :desc)
                        .page(params[:page])
                        .per(10)
  end

  def load_approved_course_kinds
    @approved_course_kinds ||=
      Event::Kind.includes(:translations)
                 .where(id: approved_approvals.distinct.pluck('events.kind_id'))
  end

  def approved_approvals
    Event::Approval
      .includes(:participation, :approvee, event: :groups)
      .joins(approvee: :primary_group, application: { participation: :event })
      .where('groups.lft >= :lft AND groups.rgt <= :rgt', lft: group.lft, rgt: group.rgt)
      .where(layer: group.class.name.demodulize.downcase, approved: true)
  end

  def course_kind_id
    params[:course_kind_id]
  end

  def authorize_action
    authorize!(:index_pending_approvals, group)
  end

end
