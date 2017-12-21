# frozen_string_literal: true

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module FilterNavigation
    class Events < ::FilterNavigation::Events

      def init_items
        super
        filter_item('canton')
      end

    end
  end
end
