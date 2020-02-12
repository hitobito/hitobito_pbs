class AddStructuredCommentsToEventApprovals < ActiveRecord::Migration[4.2]
  def change
    add_column :event_approvals, :current_occupation, :string
    add_column :event_approvals, :current_level, :string
    add_column :event_approvals, :occupation_assessment, :text
    add_column :event_approvals, :strong_points, :text
    add_column :event_approvals, :weak_points, :text
  end
end
