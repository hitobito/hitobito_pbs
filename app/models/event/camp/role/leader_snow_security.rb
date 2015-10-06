module Event::Camp::Role
  class LeaderSnowSecurity < ::Event::Role

    self.permissions = [:participations_read]

    self.kind = :leader

  end
end
