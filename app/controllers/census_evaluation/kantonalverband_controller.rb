# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CensusEvaluation::KantonalverbandController < CensusEvaluation::BaseController

  self.sub_group_type = Group::Abteilung

  def remind
    authorize!(:remind_census, group)

    abteilung = evaluation.sub_groups.find(params[:abteilung_id])
    CensusReminderJob.new(current_user, evaluation.current_census, abteilung).enqueue!
    notice = translate('email_sent', abteilung: abteilung)

    respond_to do |format|
      format.html { redirect_to census_kantonalverband_group_path(group), notice: notice }
      format.js   { flash.now.notice = notice }
    end
  end

end
