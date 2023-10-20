# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Group::Root < ::Group
  self.layer = true

  self.event_types = [] # only managing structure, does not have events (as of 2023-05-23)

  class Admin < ::Role
    self.permissions = [:layer_and_below_full, :admin]
    self.two_factor_authentication_enforced = true
  end

  roles Admin

  children Group::Bund, Group::Silverscouts
end
