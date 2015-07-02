# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationAbility
  extend ActiveSupport::Concern

  include Pbs::EventConstraints

  included do
    on(Event::Participation) do
      general(:update, :destroy).not_closed_or_admin
      general(:create).at_least_one_group_not_deleted_and_not_closed_or_admin
    end
  end

end
