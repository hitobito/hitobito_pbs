#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CrisesController < ApplicationController

  before_action :authorize_action

  def create
    @crisis = Crisis.new(creator: current_user, group: group)
    authorize!(:create, @crisis)

    if @crisis.save
      CrisisMailer.triggered(@crisis).deliver_now
      session[:crisis] = true
    else
      flash[:alert] = @crisis.errors.full_messages.join("\n")
    end

    redirect_to :back
  end

  def acknowledge
    if crisis.created_at > 3.days.ago
      crisis.update(acknowledged: true)
      CrisisMailer.acknowledged(@crisis, current_user).deliver_now
    else
      flash[:alert] = t('.to_old')
    end

    redirect_to :back
  end

  private

  def crisis
    @crisis ||= Crisis.find_by(id: params[:crisis_id])
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def authorize_action
    authorize!(:create, Crisis)
  end

end
