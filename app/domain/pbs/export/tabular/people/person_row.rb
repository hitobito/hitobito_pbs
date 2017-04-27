# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Tabular
      module People
        module PersonRow
          extend ActiveSupport::Concern

          def salutation
            entry.salutation_value
          end

          def kantonalverband_id
            entry.kantonalverband.try(:pbs_shortname)
          end

          def layer_group_id
            entry.try(:primary_group).try(:layer_group).try(:id)
          end

        end
      end
    end
  end
end
