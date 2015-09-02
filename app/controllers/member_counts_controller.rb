# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class MemberCountsController < ApplicationController

  decorates :group

  def create
    authorize!(:create_member_counts, abteilung)

    year = MemberCounter.create_counts_for(abteilung)
    if year
      total = MemberCount.total_for_abteilung(year, abteilung).try(:total) || 0
      flash[:notice] = translate('.created_data_for_year', total: total, year: year)
    end

    year ||= Time.zone.today.year
    redirect_to census_abteilung_group_path(abteilung, year: year)
  end

  def edit
    authorize!(:update_member_counts, abteilung)
    member_count
  end

  def update
    authorize!(:update_member_counts, abteilung)

    if member_count.update_attributes(permitted_params)
      redirect_to census_abteilung_group_path(abteilung, year: year),
                  notice: translate('updated_data_for_year', year: year)
    else
      render 'edit'
    end
  end

  def destroy
    authorize!(:delete_member_counts, abteilung)

    member_count.destroy
    redirect_to census_abteilung_group_path(abteilung, year: year),
                notice: translate('.deleted_data_for_year', year: year)
  end

  private

  def member_count
    @member_count ||= abteilung.member_counts.where(year: year).first!
  end

  def abteilung
    @group ||= Group::Abteilung.find(params[:group_id])
  end

  def year
    @year ||= Census.current.try(:year) ||
              fail(ActiveRecord::RecordNotFound, 'No current census found')
  end

  def permitted_params
    params.require(:member_count).permit(MemberCount::COUNT_COLUMNS)
  end

end
