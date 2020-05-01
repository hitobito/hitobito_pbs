#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddGroupHealthToServiceTokens < ActiveRecord::Migration[4.2]
  def change
    add_column(:service_tokens, :group_health, :boolean, default: false, null: false)
  end
end
