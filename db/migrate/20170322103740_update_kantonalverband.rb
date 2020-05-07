class UpdateKantonalverband < ActiveRecord::Migration[4.2]

  def up

    Person.find_each do |p|
      p.reset_kantonalverband!
    end

  end

end
