# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::ApprovalAbility < AbilityDsl::Base

  on(Event::Approval) do
    permission(:approve_applications).may(:approve, :reject).for_approvals_in_layer
  end

  def for_approvals_in_layer
    (subject.roles & user.roles.collect(&:class)).present?
  end

end
