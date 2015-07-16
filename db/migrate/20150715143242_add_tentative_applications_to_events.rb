# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddTentativeApplicationsToEvents < ActiveRecord::Migration
  def change
    add_column(:events, :tentative_applications, :boolean, null: false, default: false)

    Event.reset_column_information # to make new column appear
  end
end
