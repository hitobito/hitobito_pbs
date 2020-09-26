# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddGroupsDescription < ActiveRecord::Migration[4.2]
  def change
    unless column_exists?(:groups, :description)
      add_column(:groups, :description, :text)
    end
  end
end
