#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


Fabricator(:people_relation) do
  head { Fabricate(:person) }
  kind   { :sibling }
  tail  { Fabricate(:person) }
end
