class AddPeoplePronouns < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :pronouns, :string
  end
end
