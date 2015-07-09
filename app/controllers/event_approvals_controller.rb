# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.
#
class EventApprovalsController < ApplicationController

  attr_reader :entries

  helper_method :entries

  def layer
    authorize!(:approve, Event::Approval.new(layer: layer_name))
    @entries = Event::Approval.pending(group)
  end

  private

  def group
    @group ||= Group.find(params[:id])
  end

  def layer_name
    group.class.name.demodulize.downcase
  end

end
