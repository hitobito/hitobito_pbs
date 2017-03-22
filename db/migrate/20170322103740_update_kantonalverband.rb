class UpdateKantonalverband < ActiveRecord::Migration

  def up

    Person.find_each do |p|
      p.reset_kantonalverband!
    end

  end

end
