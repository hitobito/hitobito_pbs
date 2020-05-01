class AddGroupHealthAttributeToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column(:groups, :group_health, :boolean, default: false, null: false)
  end
end
