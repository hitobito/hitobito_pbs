# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::GroupDecorator
  extend ActiveSupport::Concern

  def supercamps(exclude_id = nil)
    events.where(allow_sub_camps: true, state: 'created').where.not(id: exclude_id)
  end

  def supercamps_on_group_and_above(exclude_id = nil)
    supercamps(exclude_id) + (root? ? [] : parent.supercamps_on_group_and_above(exclude_id))
  end

end
