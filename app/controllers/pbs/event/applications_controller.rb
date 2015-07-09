# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :approve, :approver
    alias_method_chain :reject, :approver
  end

  def approve_with_approver
    approver.approve(permitted_params[:comment], current_user)
    flash[:notice] = translate(:approved)
    redirect_to group_event_participation_path(group, participation.event_id, participation)
  end

  def reject_with_approver
    approver.reject(permitted_params[:comment], current_user)
    flash[:notice] = translate(:rejected)
    redirect_to group_event_participation_path(group, participation.event_id, participation)
  end

  def approver
    @approver ||= Event::Approver.new(participation)
  end

  def permitted_params
    params.require(:event_approval).permit(:comment)
  end

end
