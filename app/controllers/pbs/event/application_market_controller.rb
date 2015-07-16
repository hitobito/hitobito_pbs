# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationMarketController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :add_participant, :state
    alias_method_chain :remove_participant, :state
  end

  def add_participant_with_state
    add_participant_without_state
    participation.update!(state: 'assigned')
  end

  def remove_participant_with_state
    remove_participant_without_state
    participation.update!(state: 'applied')
  end

end
