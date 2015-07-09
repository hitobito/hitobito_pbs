# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Application) do
      permission(:approve_applications).may(:approve, :reject).for_approvals_in_layer
    end
  end

  def for_approvals_in_layer
    if subject.next_open_approval
      (subject.next_open_approval.roles & user.roles.collect(&:class)).present?
    end
  end


end
