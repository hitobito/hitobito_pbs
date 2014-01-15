# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class MemberCountsController < ApplicationController

  decorates :group


  def edit
    authorize!(:update_member_counts, abteilung)
    member_count
  end

  def update
    authorize!(:update_member_counts, abteilung)

    if member_count.update_attributes(params[:member_count])
      flash[:notice] = "Die Mitgliederzahlen für #{year} wurden erfolgreich gespeichert"
      redirect_to census_abteilung_group_path(abteilung, year: year)
    else
      render 'edit'
    end
  end

  def create
    authorize!(:create_member_counts, abteilung)

    if year = MemberCounter.create_counts_for(abteilung)
      total = MemberCount.total_for_abteilung(year, abteilung).try(:total) || 0
      flash[:notice] = "Die Zahlen von Total #{total} Mitgliedern wurden für #{year} erfolgreich erzeugt."
    end

    year ||= Date.today.year
    redirect_to census_abteilung_group_path(abteilung, year: year)
  end

  private

  def member_count
    @member_count ||= abteilung.member_counts.where(year: year).first!
  end

  def abteilung
    @group ||= Group::Abteilung.find(params[:group_id])
  end

  def year
    @year ||= params[:year] ? params[:year].to_i : fail(ActiveRecord::RecordNotFound, 'year required')
  end
end
