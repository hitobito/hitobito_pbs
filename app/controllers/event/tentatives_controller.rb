# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::TentativesController < ApplicationController

  helper_method :group, :entry
  before_filter :load_group_and_event

  decorates :event, :group

  def index
    authorize!(:list_tentatives, @event)

    @counts = @event.
      participations.
      tentative.
      joins(person: :primary_group).
      joins('LEFT OUTER JOIN groups layer_groups on groups.layer_group_id = layer_groups.id').
      group('layer_groups.id', 'layer_groups.name').
      order('layer_groups.id desc').
      count
  end

  private

  def load_group_and_event
    @group = Group.find(params[:group_id])
    @event = Event::Course.find(params[:event_id])
  end

end
