#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class UpgradeCampsToNestedSet < ActiveRecord::Migration
  def change
    nested_set_class = Event

    add_column nested_set_class.table_name, :lft, :integer
    add_column nested_set_class.table_name, :rgt, :integer

    reversible do |dirs|
      dirs.up do

        if nested_set_class.respond_to?(:rebuild!)
          say_with_time %Q[Building the "nested set"-tree/-forest for #{nested_set_class.name}] do
            nested_set_class.reset_column_information
            nested_set_class.rebuild!
          end
        else
          say %Q[#{nested_set_class.name} is not defined as "nested set" in ruby]
        end
      end
    end

    add_index nested_set_class.table_name, :lft
    add_index nested_set_class.table_name, :rgt
  end
end
