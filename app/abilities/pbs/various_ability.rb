#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::VariousAbility
  extend ActiveSupport::Concern

  included do
    on(Census) do
      permission(:layer_and_below_full).may(:manage).if_mitarbeiter_gs
    end

    on(BlackList) do
      class_side(:manage).if_black_list_role
    end

    on(Crisis) do
      permission(:crisis_trigger).may(:manage).all
    end
  end

  def if_mitarbeiter_gs
    role_type?(Group::Bund::MitarbeiterGs)
  end

  def if_black_list_role
    role_type?(Group::Bund::Geschaeftsleitung) ||
      role_type?(Group::Bund::LeitungKernaufgabeKommunikation)
  end

end
