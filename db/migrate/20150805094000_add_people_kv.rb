class AddPeopleKv < ActiveRecord::Migration
  def change
    add_column :people, :kantonalverband_id, :integer

    Person.reset_column_information

    Person.find_each(&:reset_kantonalverband!)
  end
end
