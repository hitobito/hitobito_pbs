class AddGroupsDescription < ActiveRecord::Migration
  def change
    add_column :groups, :description, :text
  end
end
