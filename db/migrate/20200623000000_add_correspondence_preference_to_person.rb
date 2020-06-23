# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddCorrespondencePreferenceToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :prefers_digital_correspondence, :boolean, null: false, default: false
  end
end
