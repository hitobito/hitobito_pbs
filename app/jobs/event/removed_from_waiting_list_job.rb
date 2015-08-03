# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::RemovedFromWaitingListJob < BaseJob

  self.parameters = [:participation_id, :current_user_id, :locale]

  def initialize(participation, current_user)
    super()
    @participation_id = participation.id
    @current_user_id = current_user.id
  end

  def perform
    return unless participation

    set_locale

    Event::ParticipationMailer.
      removed_from_waiting_list(participation, current_user).deliver
  end

  private

  def participation
    @participation ||= Event::Participation.find(@participation_id)
  end

  def current_user
    @current_user ||= Person.find(@current_user_id)
  end

end
