# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Dropdown
    module PeopleExport
      extend ActiveSupport::Concern

      def is_course?(event)
        event.is_a?(::Event::Course)
      end

      def is_camp?(event)
        event.is_a?(::Event::Camp)
      end

    end
  end
end
