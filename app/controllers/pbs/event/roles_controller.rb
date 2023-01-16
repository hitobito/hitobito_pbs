# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::RolesController
  extend ActiveSupport::Concern

  included do
    self.permitted_attrs += [{ participation_attributes: :j_s_data_sharing_accepted }]
  end
end
