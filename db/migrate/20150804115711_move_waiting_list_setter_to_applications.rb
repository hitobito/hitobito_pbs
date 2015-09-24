class MoveWaitingListSetterToApplications < ActiveRecord::Migration
  def up
    remove_column(:event_participations, :waiting_list_setter_id)
    add_column(:event_applications, :waiting_list_setter_id, :integer)

    Event::Participation.reset_column_information
    Event::Application.reset_column_information
  end

  def down
    remove_column(:event_applications, :waiting_list_setter_id)
    add_column(:event_participations, :waiting_list_setter_id, :integer)
  end
end
