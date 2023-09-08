# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Group::Silverscouts < ::Group
  self.layer = true

  class Verantwortung < ::Role
    self.permissions = [:layer_and_below_full]
  end

  class Lesezugriff < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class PowerUser < ::Role
    self.permissions = [:layer_full]
  end

  roles Verantwortung, Lesezugriff, PowerUser

  children Silverscouts::Region
end
