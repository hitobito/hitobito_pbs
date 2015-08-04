class MoveWaitingListSetterToApplications < ActiveRecord::Migration
  def up
    remove_column(:event_participations, :waiting_list_setter_id)
    add_column(:event_applications, :waiting_list_setter_id, :integer)
  end

  def down
    remove_column(:event_applications, :waiting_list_setter_id)
    add_column(:event_participations, :waiting_list_setter_id, :integer)
  end
end
