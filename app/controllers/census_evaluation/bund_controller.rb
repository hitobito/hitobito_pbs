# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CensusEvaluation::BundController < CensusEvaluation::BaseController

  self.sub_group_type = Group::Kantonalverband

  def index
    super

    respond_to do |format|
      format.html do
        @abteilungen = abteilung_confirmation_ratios if evaluation.current_census_year?
      end
    end
  end

  private

  def abteilung_confirmation_ratios
    @sub_groups.each_with_object({}) do |kantonalverband, hash|
      hash[kantonalverband.id] = { confirmed: number_of_confirmations(kantonalverband),
                                   total: number_of_abteilungen(kantonalverband) }
    end
  end

  def number_of_confirmations(kantonalverband)
    MemberCount.where(kantonalverband_id: kantonalverband.id, year: year).
                distinct.
                count(:abteilung_id)
  end

  def number_of_abteilungen(kantonalverband)
    kantonalverband.descendants.without_deleted.where(type: Group::Abteilung.sti_name).count
  end

end
