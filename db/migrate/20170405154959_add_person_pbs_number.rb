# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddPersonPbsNumber < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :pbs_number, :string

    Person.reset_column_information

    if Person.connection.adapter_name.downcase =~ /mysql/
      Person.update_all("pbs_number = INSERT(INSERT(LPAD(id, 9, 0), 7, 0, '-'), 4, 0, '-')")
    else
      Person.find_each do |p|
        p.send(:set_pbs_number!)
      end
    end
  end
end
