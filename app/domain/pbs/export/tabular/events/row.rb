#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Pbs::Export::Tabular::Events
  module Row
    extend ActiveSupport::Concern

    included do
      dynamic_attributes[/^advisor_/] = :contactable_attribute
      alias_method_chain :leader, :camp
    end

    def advisor
      # Only Event::Course provides restricted advisor role
      entry.try(:advisor)
    end

    def leader_with_camp
      # for reasons unknowns (86f7c17) Event::Camp::Role::Leader kind is set to nil
      if entry.is_a?(Event::Camp)
        entry.participations_for(Event::Camp::Role::Leader).first.try(:person)
      else
        leader_without_camp
      end
    end
  end
end
