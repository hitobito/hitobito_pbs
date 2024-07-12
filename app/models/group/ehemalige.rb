# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Group::Ehemalige < ::Group
  class Mitglied < ::Role
  end

  class Leitung < ::Role
    self.permissions = [:group_full]
  end

  roles Mitglied, Leitung

  children Group::Ehemalige
end
