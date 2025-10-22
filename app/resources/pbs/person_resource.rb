# frozen_string_literal: true

#  Copyright (c) 2025,  Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PersonResource
  extend ActiveSupport::Concern

  included do
    attribute :pronouns, :string, writable: false, sortable: false
  end
end
