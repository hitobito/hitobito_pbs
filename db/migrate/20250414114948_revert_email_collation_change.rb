# frozen_string_literal: true

#  Copyright (c) 2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


class RevertEmailCollationChange < ActiveRecord::Migration[7.1]
  def up
    say_with_time "setting the default collation" do
      list_of_email_columns.each do |table, column|
        execute "ALTER TABLE #{table} ALTER COLUMN #{column} SET DATA TYPE varchar;"
      end
    end
  end

  private

  def list_of_email_columns
    [
      [:black_lists, :email]
    ]
  end
end
