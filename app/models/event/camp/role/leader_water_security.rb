module Event::Camp::Role
  class LeaderWaterSecurity < ::Event::Role

    self.permissions = [:participations_read]

    self.kind = :leader

  end
end
