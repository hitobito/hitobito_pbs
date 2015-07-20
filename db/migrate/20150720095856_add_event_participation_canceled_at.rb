class AddEventParticipationCanceledAt < ActiveRecord::Migration
  def change
    add_column :event_participations, :canceled_at, :date

    Event::Participation.reset_column_information
  end
end
