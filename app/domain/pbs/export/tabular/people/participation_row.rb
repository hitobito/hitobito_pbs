# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Tabular
      module People
        module ParticipationRow

          def bsv_days
            participation.bsv_days || participation.event.bsv_days
          end

          def has_siblings_in_event
            event = participation.event

            ::Person::FamilyMemberFinder.new(participation.person)
                                        .family_members_in_context(event, kind: :sibling).any?
          end
          
        end
      end
    end
  end
end
