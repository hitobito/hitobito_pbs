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
      permission(:crisis_trigger).may(:create, :update).on_abteilung_if_krisenteam
    end
  end

  def if_mitarbeiter_gs
    role_type?(Group::Bund::MitarbeiterGs)
  end

  def if_black_list_role
    role_type?(Group::Bund::Geschaeftsleitung) ||
      role_type?(Group::Bund::LeitungKernaufgabeKommunikation)
  end

  def on_abteilung_if_krisenteam
    subject.group.is_a?(Group::Abteilung) && if_krisenteam
  end

  def if_krisenteam
    layer_ids = subject.group.layer_hierarchy.collect(&:id)
    subject.group.try(:layer) && permission_in_layers?(layer_ids) &&
      (krisenteam_bund || krisenteam_kanton)
  end

  def krisenteam_bund
    permission_in_layers?([Group::Bund.first.id])
  end

  def krisenteam_kanton
    !subject.group.is_a?(Group::Kantonalverband)
  end
end
