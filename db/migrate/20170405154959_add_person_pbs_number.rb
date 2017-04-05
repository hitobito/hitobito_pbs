# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddPersonPbsNumber < ActiveRecord::Migration
  def change
    add_column :people, :pbs_number, :string

    Person.reset_column_information

    Person.find_each do |p|
      p.send(:set_pbs_number!)
    end
  end
end
