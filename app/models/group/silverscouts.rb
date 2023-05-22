# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Group::Silverscouts < ::Group
  self.layer = true

  class Leitung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Mitglied < ::Role
  end

  roles Leitung, Mitglied
end
