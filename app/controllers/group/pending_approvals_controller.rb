# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Group::PendingApprovalsController < ApplicationController

  decorates :group

  before_action :authorize_action

  def index
    @approvals =
      Event::Approval.pending(group).
      includes(:participation, :approvee, event: [:dates, :groups]).
      order('event_participations.created_at ASC')
    @approver_roles = approver_roles
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

  def approver_roles
    group.class.role_types.select { |t| t.permissions.include?(:approve_applications) }
  end

  def authorize_action
    authorize!(:index_pending_approvals, group)
  end

end
