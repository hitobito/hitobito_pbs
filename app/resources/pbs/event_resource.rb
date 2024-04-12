# frozen_string_literal: true

#  Copyright (c) 2024,  Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventResource
  extend ActiveSupport::Concern

  included do
    attribute :advisor_id, :integer, writable: false, sortable: false
    belongs_to :advisor, resource: PersonResource, writable: false, foreign_key: :advisor_id do
      assign do |_event, _person|
        # nothing
      end
    end
  end
end
