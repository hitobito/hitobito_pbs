class AddCourseConfirmationAttrs < ActiveRecord::Migration[4.2]
  def up
    add_column :event_kinds, :can_have_confirmations, :boolean, null: false, default: false
    add_column :event_kinds, :confirmation_name, :string, null: true
    add_column :events, :has_confirmations, :boolean, null: false, default: true
  end

  def down
    remove_column :events, :has_confirmations
    remove_column :event_kinds, :confirmation_name
    remove_column :event_kinds, :can_have_confirmations
  end
end
