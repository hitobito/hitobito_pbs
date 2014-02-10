# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Csv
      module People
        module PersonRow
          extend ActiveSupport::Concern

          def salutation
            entry.salutation_value
          end
        end
      end
    end
  end
end
