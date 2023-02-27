# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Person
    module AddRequest
      module Approver
        module Event
          extend ActiveSupport::Concern

          private

          def build_entity
            super.tap do |participation|
              participation.j_s_data_sharing_accepted = true
            end
          end
        end
      end
    end
  end
end
