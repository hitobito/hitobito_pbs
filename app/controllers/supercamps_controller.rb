#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class SupercampsController < ApplicationController
  skip_authorization_check

  helper_method :group, :camp_id
  decorates :group

  respond_to :js

  def available
    group
    supercamps_on_group_and_above
  end

  def connect
    flash[:event_with_merged_supercamp] = event_with_merged_supercamp
    redirect_to request.referer
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
  end

  def supercamps_on_group_and_above
    @supercamps_on_group_and_above = group.decorate.supercamps_on_group_and_above(camp_id)
  end

  def camp_id
    @camp_id ||= params[:camp_id]
  end

  def event_with_merged_supercamp
    params[:event].merge({'parent_id' => params[:supercamp_id]})
  end

end
