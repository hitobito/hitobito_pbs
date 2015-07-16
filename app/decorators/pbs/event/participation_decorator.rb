# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationDecorator
  extend ActiveSupport::Concern

  included do
    alias_method_chain :to_s, :state
  end

  def state_translated(state = model.state)
    if possible_states.present? && state
      h.t("activerecord.attributes.event/participation.states.#{state}")
    else
      state
    end
  end

  def to_s_with_state(*args)
    s = to_s_without_state(*args)
    s << " (#{state_translated})" if %w(rejected canceled absent).include?(model.state)
    s
  end

end
