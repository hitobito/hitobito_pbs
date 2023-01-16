# encoding: utf-8

#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::RestrictedRole
  extend ActiveSupport::Concern

  include Event::RestrictedRole

  private

  def build_restricted_role(role, id)
    super.tap do |role|
      role.participation.j_s_data_sharing_accepted = true if role.participation.j_s_data_sharing_acceptance_required?
      end
  end
end
