#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::TableDisplays::People
  module LayerGroupLabelColumn
    protected

    def allowed?(object, attr, original_object, original_attr)
      # In events, evaluate the permission on the participation, not on the person
      ability.can? required_permission(attr), original_object
    end
  end
end
