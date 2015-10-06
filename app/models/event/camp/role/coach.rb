module Event::Camp::Role
  class Coach < ::Event::Role

    self.permissions = [:event_full, :participations_full]

    self.kind = nil

  end
end
