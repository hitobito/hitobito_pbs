# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddCourseFields < ActiveRecord::Migration
  def change
    add_column :events, :language_de, :boolean, null: false, default: false
    add_column :events, :language_fr, :boolean, null: false, default: false
    add_column :events, :language_it, :boolean, null: false, default: false
    add_column :events, :language_en, :boolean, null: false, default: false
    add_column :events, :express_fee, :string
  end
end
