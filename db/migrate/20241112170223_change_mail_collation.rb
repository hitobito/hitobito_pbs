# frozen_string_literal: true

class ChangeMailCollation < ActiveRecord::Migration[6.1]
  def list_of_email_columns
    [
      [:black_lists, :email]
    ]
  end

  def up
    say_with_time "setting the case-insensitive collation" do
      list_of_email_columns.each do |table, column|
        execute "ALTER TABLE #{table} ALTER COLUMN #{column} SET DATA TYPE varchar COLLATE case_insensitive_emails;"
      end
    end
  end

  def down
    say_with_time "setting the default collation" do
      list_of_email_columns.each do |table, column|
        execute "ALTER TABLE #{table} ALTER COLUMN #{column} SET DATA TYPE varchar;"
      end
    end
  end
end
