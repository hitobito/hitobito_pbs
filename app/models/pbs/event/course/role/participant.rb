# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Course::Role::Participant
  extend ActiveSupport::Concern

  included do
    alias_method_chain :set_participation_active, :tentative
  end

  def set_participation_active_with_tentative
    if !participation.tentative?
      set_participation_active_without_tentative
    end
  end

end
