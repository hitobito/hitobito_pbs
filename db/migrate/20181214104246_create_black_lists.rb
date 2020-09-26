class CreateBlackLists < ActiveRecord::Migration[4.2]
  def change
    create_table :black_lists do |t|
      t.string :first_name
      t.string :last_name
      t.string :pbs_number
      t.string :email
      t.string :phone_number
      t.string :reference_name
      t.string :reference_phone_number

      t.timestamps null: false
    end
  end
end
