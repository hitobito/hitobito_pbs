#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


class CrisisInformerJob < RecurringJob

  run_every 1.day

  def perform_internal
    inform_canton_for_completed_crises
  end

  private

  def inform_canton_for_completed_crises
    incompleted_crises.each do |crisis|
      crisis.update(completed: true)
      CrisisMailer.completed(crisis).deliver_now
    end
  end

  def incompleted_crises
    Crisis.where(completed: false)
      .where('(created_at < :one_week AND acknowledged = :acknowledged) OR '\
             '(created_at < :three_days AND acknowledged != :acknowledged)',
             acknowledged: true, one_week: 1.week.ago, three_days: 3.days.ago)
  end

end
