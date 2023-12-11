class RemoveBrotherAndSisterFromPersons < ActiveRecord::Migration[6.1]
  def change
    remove_column :people, :brother_and_sisters, :boolean, default: false, null: false
  end
end
