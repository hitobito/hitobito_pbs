# frozen_string_literal: true

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Household

  def household_attrs
    super.merge(
      prefers_digital_correspondence: @reference_person.prefers_digital_correspondence
    )
  end
end
