class AddStructuredCommentsToEventApprovals < ActiveRecord::Migration
  def change
    add_column :event_approvals, :current_occupation,    :string, null: false
    add_column :event_approvals, :current_level,         :string, null: false
    add_column :event_approvals, :occupation_assessment, :text,   null: false
    add_column :event_approvals, :strong_points,         :text,   null: false
    add_column :event_approvals, :weak_points,           :text,   null: false

    change_column_null :event_approvals, :comment, false, ''
  end
end
