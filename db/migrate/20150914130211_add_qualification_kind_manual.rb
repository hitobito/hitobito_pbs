# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddQualificationKindManual < ActiveRecord::Migration
  def change
    add_column :qualification_kinds, :manual, :boolean, null: false, default: true

    QualificationKind.reset_column_information
  end
end
