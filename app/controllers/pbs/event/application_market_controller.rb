# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationMarketController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :put_on_waiting_list, :setter
    alias_method_chain :remove_from_waiting_list, :setter
  end

  def remove_from_waiting_list_with_setter
    if application.waiting_list_setter && application.waiting_list_setter != current_user
      Event::RemovedFromWaitingListJob.
        new(participation, application.waiting_list_setter, current_user).
        enqueue!
    end

    application.update!(waiting_list: false,
                        waiting_list_setter: nil)

    render 'waiting_list'
  end

  def put_on_waiting_list_with_setter
    application.update!(waiting_list: true,
                        waiting_list_comment: params[:event_application][:waiting_list_comment],
                        waiting_list_setter: current_user)

    render 'waiting_list'
  end

end
