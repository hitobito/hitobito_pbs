# frozen_string_literal: true

#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::SearchStrategies
  module PersonSearch
    extend ActiveSupport::Concern

    prepended do
      self.searchable_identifiers = searchable_identifiers.merge({
        pbs_number: /\A\d{3}-\d{3}-\d{3}\z/
      })
    end
  end
end
