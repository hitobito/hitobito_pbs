#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Tabular::MemberCounts
  class List < Export::Tabular::Base
    self.model_class = MemberCount
    self.row_class = Export::Tabular::MemberCounts::Row

    def attributes
      model_class.column_names.collect(&:to_sym)
    end
  end
end
