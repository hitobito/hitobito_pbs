# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::AssignedFromWaitingListJob < BaseJob

  self.parameters = [:participation_id, :setter_id, :current_user_id, :locale]

  def initialize(participation, setter, current_user)
    super()
    @participation_id = participation.id
    @setter_id = setter.id
    @current_user_id = current_user.id
  end

  def perform
    return unless participation

    set_locale

    Event::ParticipationMailer.
      assigned_from_waiting_list(participation, setter, current_user).deliver_now
  end

  private

  def participation
    @participation ||= Event::Participation.find(@participation_id)
  end

  def setter
    @setter ||= Person.find(@setter_id)
  end

  def current_user
    @current_user ||= Person.find(@current_user_id)
  end

end
