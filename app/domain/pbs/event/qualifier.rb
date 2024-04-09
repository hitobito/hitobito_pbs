# frozen_string_literal: true

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Qualifier
  extend ActiveSupport::Concern

  private

  def issue_qualifications
    super.tap do
      @created.each do |q|
        q.update!(event_participation: @participation)
      end
    end
  end
end
