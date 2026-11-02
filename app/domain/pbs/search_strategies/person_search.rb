# frozen_string_literal: true

#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::SearchStrategies
  module PersonSearch
    PBS_NUMBER_FORMAT = /\A\d{3}-\d{3}-\d{3}\z/

    def search_identifiers
      return super unless term.match?(PBS_NUMBER_FORMAT)

      accessible_scope.where(id: term.delete("-").to_i)
    end
  end
end
