# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipantAssigner

  extend ActiveSupport::Concern

  included do
    alias_method_chain :remove_from_waiting_list, :setter
  end

  private

  def remove_from_waiting_list_with_setter
    if application.waiting_list_setter && application.waiting_list_setter != user
      Event::AssignedFromWaitingListJob.
        new(participation, application.waiting_list_setter, user).
        enqueue!
    end

    application.update!(waiting_list: false, waiting_list_setter: nil)
  end

end
