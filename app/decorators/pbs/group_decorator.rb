# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::GroupDecorator
  extend ActiveSupport::Concern

  def upcoming_supercamps
    events.upcoming.where(allow_sub_camps: true, state: 'created').distinct
  end

  def upcoming_supercamps_on_group_and_above
    upcoming_supercamps + (root? ? [] : parent.upcoming_supercamps_on_group_and_above)
  end

end
