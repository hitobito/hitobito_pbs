module Event::Camp::Role
  class Helper < ::Event::Role

    self.permissions = [:participations_read]

    self.kind = :helper

  end
end
