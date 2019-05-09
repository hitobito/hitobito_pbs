#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CrisesController < ApplicationController

  def create
    @crisis = Crisis.new(creator: current_user, group: group)
    authorize!(:create, @crisis)

    if @crisis.save
      CrisisMailer.triggered(@crisis).deliver_later
      session[:crisis] = true
    else
      flash[:alert] = @crisis.errors.full_messages.join("\n")
    end

    redirect_to group
  end

  def update
    crisis = group.crises.find(params[:id])
    authorize!(:update, crisis)
    if crisis.created_at > 3.days.ago
      crisis.update(acknowledged: true)
      CrisisMailer.acknowledged(crisis, current_user).deliver_later
    else
      flash[:alert] = t('.too_old')
    end
    redirect_to group
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
  end

end
