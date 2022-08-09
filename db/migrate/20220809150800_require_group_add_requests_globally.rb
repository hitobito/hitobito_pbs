# frozen_string_literal: true

#  Copyright (c) 2022-2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class RequireGroupAddRequestsGlobally < ActiveRecord::Migration[6.1]
  def up
    say_with_time "Updating all groups to require a request to be added" do
      Group.update_all require_person_add_requests: true
    end
  end

  def down
    # nope, one-way data-migration
  end
end
