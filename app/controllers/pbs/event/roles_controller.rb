# encoding: utf-8

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::RolesController
  def build_entry
    super.tap do |role|
      attrs = params[:event_role] || {}
      accepted = attrs.dig(:participation_attributes, :j_s_data_sharing_accepted)
      role.participation.j_s_data_sharing_accepted = true?(accepted)
    end
  end
end
