# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationMarketController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :assigner_add_participant, :waiting_list_setter
    alias_method_chain :remove_participant, :waiting_list_setter
    alias_method_chain :remove_from_waiting_list, :waiting_list_setter
    alias_method_chain :put_on_waiting_list, :waiting_list_setter
  end

  def assigner_add_participant_with_waiting_list_setter
    with_waiting_list_notification(Event::AssignedFromWaitingListJob) do
      assigner_add_participant_without_waiting_list_setter
    end
  end

  def remove_participant_with_waiting_list_setter
    remove_participant_without_waiting_list_setter
    participation.update(waiting_list_setter: current_user)
  end

  def remove_from_waiting_list_with_waiting_list_setter
    with_waiting_list_notification(Event::RemovedFromWaitingListJob) do
      remove_from_waiting_list_without_waiting_list_setter
    end
  end

  def put_on_waiting_list_with_waiting_list_setter
    put_on_waiting_list_without_waiting_list_setter
    participation.update(waiting_list_setter: current_user)
  end

  private

  def with_waiting_list_notification(job_class)
    waiting_list = participation.application.waiting_list?
    waiting_list_setter = participation.waiting_list_setter
    yield

    if waiting_list && waiting_list_setter && waiting_list_setter != current_user
      job_class.new(participation, current_user).enqueue!
    end
  end


end
